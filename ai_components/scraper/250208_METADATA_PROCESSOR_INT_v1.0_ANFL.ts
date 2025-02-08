// ----------------------------------------------------------------------------
// File: 250208_METADATA_PROCESSOR_INT_v1.0_ANFL.ts
// Location: /Volumes/mattstack/VSCode/AeonNovaFutureLabs/ai_components/scraper/
//
// Purpose: Process and store chat metadata efficiently
// Security Level: Confidential
// Owner: Infrastructure Team
// Version: 1.0
// Last Modified: 2025-02-08
//
// References:
// - 250208_CHAT_SCRAPER_INT_v1.0_ANFL.ts
// - intelligent-indexer.py
// ----------------------------------------------------------------------------

import { createHash } from 'crypto';
import { writeFile, readFile, mkdir } from 'fs/promises';
import { join } from 'path';
import { VectorStore, Vector, SearchParams } from '../vector_store/core/types';

interface ChatMetadata {
  id: string;
  title: string;
  summary: string;
  topics: string[];
  key_points: string[];
  source: string;
  timestamp: string;
  message_count: number;
  token_count: number;
  embedding: number[];
  reference_path: string;
}

interface ProcessedChat {
  metadata: ChatMetadata;
  content_hash: string;
}

interface ChatMessage {
  role: string;
  content: string;
  timestamp: string;
}

interface ChatData {
  id: string;
  title: string;
  messages: ChatMessage[];
  metadata: {
    source: string;
    scraped_at: string;
  };
}

export class ChatMetadataProcessor {
  private vectorStore: VectorStore;
  private storageRoot: string;
  private contentRoot: string;

  constructor(
    vectorStore: VectorStore,
    storageRoot: string = '/Volumes/mattstack/VSCode/AeonNovaFutureLabs/data/chat_archive'
  ) {
    this.vectorStore = vectorStore;
    this.storageRoot = storageRoot;
    this.contentRoot = join(storageRoot, 'content');
    this.initializeStorage();
  }

  private async initializeStorage(): Promise<void> {
    await mkdir(this.storageRoot, { recursive: true });
    await mkdir(this.contentRoot, { recursive: true });
  }

  /**
   * Process chat data into efficient metadata format
   */
  async processChatData(chatData: ChatData): Promise<ProcessedChat> {
    // Generate content hash
    const contentHash = this.generateHash(JSON.stringify(chatData.messages));

    // Extract key information
    const summary = await this.generateSummary(chatData.messages);
    const topics = await this.extractTopics(chatData.messages);
    const keyPoints = await this.extractKeyPoints(chatData.messages);
    const tokenCount = await this.countTokens(chatData.messages);
    const embedding = await this.generateEmbedding(summary);

    // Create reference path
    const referencePath = join(
      this.contentRoot,
      `${chatData.metadata.source}_${contentHash}.json`
    );

    // Create metadata
    const metadata: ChatMetadata = {
      id: chatData.id,
      title: chatData.title,
      summary,
      topics,
      key_points: keyPoints,
      source: chatData.metadata.source,
      timestamp: chatData.metadata.scraped_at,
      message_count: chatData.messages.length,
      token_count: tokenCount,
      embedding,
      reference_path: referencePath
    };

    // Store full content
    await this.storeContent(referencePath, chatData.messages);

    // Store embedding in vector store
    const vector: Vector = {
      id: chatData.id,
      values: embedding,
      metadata: {
        title: chatData.title,
        summary,
        source: chatData.metadata.source,
        reference_path: referencePath
      }
    };

    await this.vectorStore.store_vectors([vector]);

    return {
      metadata,
      content_hash: contentHash
    };
  }

  /**
   * Generate summary using extractive summarization
   */
  private async generateSummary(messages: ChatMessage[]): Promise<string> {
    // Extract key sentences
    const sentences = messages
      .map(m => m.content.split('. '))
      .flat()
      .filter(s => s.length > 0);

    // Score sentences based on importance
    const scores = sentences.map(s => ({
      text: s,
      score: this.scoreSentence(s)
    }));

    // Select top sentences
    const topSentences = scores
      .sort((a, b) => b.score - a.score)
      .slice(0, 3)
      .map(s => s.text);

    return topSentences.join('. ');
  }

  /**
   * Extract main topics from messages
   */
  private async extractTopics(messages: ChatMessage[]): Promise<string[]> {
    const text = messages.map(m => m.content).join(' ');
    const words = text.toLowerCase().split(/\W+/);
    
    // Count word frequencies
    const frequencies: Record<string, number> = {};
    for (const word of words) {
      frequencies[word] = (frequencies[word] || 0) + 1;
    }

    // Get top words as topics
    return Object.entries(frequencies)
      .sort(([,a], [,b]) => b - a)
      .slice(0, 5)
      .map(([word]) => word);
  }

  /**
   * Extract key points from messages
   */
  private async extractKeyPoints(messages: ChatMessage[]): Promise<string[]> {
    const keyPoints: string[] = [];

    for (const message of messages) {
      // Look for bullet points and numbered lists
      const points = message.content.split('\n')
        .filter((line: string) => line.match(/^[-*•]|\d+\./))
        .map((line: string) => line.replace(/^[-*•]|\d+\./, '').trim());

      keyPoints.push(...points);
    }

    // Limit to top 10 key points
    return keyPoints.slice(0, 10);
  }

  /**
   * Count tokens in messages
   */
  private async countTokens(messages: ChatMessage[]): Promise<number> {
    const text = messages.map(m => m.content).join(' ');
    // Rough token count estimation
    return text.split(/\s+/).length;
  }

  /**
   * Generate embedding for text
   */
  private async generateEmbedding(text: string): Promise<number[]> {
    // TODO: Implement proper embedding generation
    // For now return dummy embedding
    return new Array(1536).fill(0).map(() => Math.random());
  }

  /**
   * Score sentence importance
   */
  private scoreSentence(sentence: string): number {
    // Simple scoring based on length and keyword presence
    const length = sentence.length;
    const hasCode = /code|function|class/.test(sentence.toLowerCase());
    const hasNumbers = /\d+/.test(sentence);
    const hasKeywords = /important|key|main|critical/.test(sentence.toLowerCase());

    return (
      (length > 50 ? 1 : 0) +
      (hasCode ? 2 : 0) +
      (hasNumbers ? 1 : 0) +
      (hasKeywords ? 1 : 0)
    );
  }

  /**
   * Generate content hash
   */
  private generateHash(content: string): string {
    return createHash('sha256')
      .update(content)
      .digest('hex')
      .slice(0, 12);
  }

  /**
   * Store full content
   */
  private async storeContent(path: string, content: any): Promise<void> {
    await writeFile(path, JSON.stringify(content, null, 2));
  }

  /**
   * Retrieve full content
   */
  async retrieveContent(metadata: ChatMetadata): Promise<any> {
    const content = await readFile(metadata.reference_path, 'utf8');
    return JSON.parse(content);
  }

  /**
   * Search chats by similarity
   */
  async searchSimilar(query: string, limit: number = 5): Promise<ChatMetadata[]> {
    const embedding = await this.generateEmbedding(query);
    
    const searchParams: SearchParams = {
      vector: embedding,
      top_k: limit
    };

    const results = await this.vectorStore.search_vectors(searchParams);

    return results.map(r => ({
      ...r.metadata,
      id: r.id,
      embedding: r.values
    })) as ChatMetadata[];
  }
}