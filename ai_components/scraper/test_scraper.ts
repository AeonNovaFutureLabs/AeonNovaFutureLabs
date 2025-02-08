// ----------------------------------------------------------------------------
// File: test_scraper.ts
// Location: /Volumes/mattstack/VSCode/AeonNovaFutureLabs/ai_components/scraper/
//
// Purpose: Test script for chat scraper and metadata processor
// Security Level: Confidential
// Owner: Infrastructure Team
// Version: 1.0
// Last Modified: 2025-02-08
// ----------------------------------------------------------------------------

import { ChatMetadataProcessor } from './250208_METADATA_PROCESSOR_INT_v1.0_ANFL';
import { VectorStore, VectorConfig } from '../vector_store/core/types';

interface TestMessage {
    role: string;
    content: string;
    timestamp: string;
}

interface TestChat {
    id: string;
    title: string;
    messages: TestMessage[];
    metadata: {
        source: string;
        scraped_at: string;
    };
}

async function testScraper() {
    try {
        // Initialize vector store
        const config: VectorConfig = {
            dimension: 1536,
            metric: 'cosine'
        };
        const vectorStore = new VectorStore(config);

        // Initialize metadata processor
        const processor = new ChatMetadataProcessor(vectorStore);

        // Test data
        const sampleChat: TestChat = {
            id: 'test-chat-1',
            title: 'Test Chat',
            messages: [
                {
                    role: 'user',
                    content: 'How do I implement a vector store?',
                    timestamp: '2025-02-08T12:00:00Z'
                },
                {
                    role: 'assistant',
                    content: `Here's how to implement a vector store:

1. Choose an embedding model
2. Set up vector database (like Pinecone)
3. Implement indexing logic
4. Add search functionality
5. Optimize performance

Key considerations:
- Dimension size
- Distance metric
- Batch processing
- Caching strategy`,
                    timestamp: '2025-02-08T12:01:00Z'
                }
            ],
            metadata: {
                source: 'claude',
                scraped_at: '2025-02-08T12:02:00Z'
            }
        };

        // Process chat data
        console.log('Processing chat data...');
        const processed = await processor.processChatData(sampleChat);
        console.log('Processed metadata:', JSON.stringify(processed.metadata, null, 2));

        // Test search
        console.log('\nTesting similar search...');
        const searchResults = await processor.searchSimilar('vector database implementation');
        console.log('Search results:', JSON.stringify(searchResults, null, 2));

        // Test content retrieval
        console.log('\nTesting content retrieval...');
        const content = await processor.retrieveContent(processed.metadata);
        console.log('Retrieved content:', JSON.stringify(content, null, 2));

        console.log('\nAll tests completed successfully');

    } catch (error) {
        console.error('Test failed:', error instanceof Error ? error.message : String(error));
        process.exit(1);
    }
}

// Run tests
testScraper().catch(console.error);