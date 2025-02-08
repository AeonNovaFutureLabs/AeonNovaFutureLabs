# Chat Scraper Component

## Overview

The Chat Scraper component is a framework-compliant tool for extracting, processing, and storing chat histories from Claude and ChatGPT. It includes:

- MCP server for scraping chat data
- Metadata processor for efficient storage and retrieval
- Vector store integration for similarity search
- Test utilities for verification

## Architecture

### Chat Scraper Server (250208_CHAT_SCRAPER_INT_v1.0_ANFL.ts)
- Implements MCP protocol for tool exposure
- Uses Puppeteer for web scraping
- Supports both Claude and ChatGPT interfaces
- Handles authentication and session management
- Provides structured chat history extraction

### Metadata Processor (250208_METADATA_PROCESSOR_INT_v1.0_ANFL.ts)
- Processes raw chat data into efficient metadata
- Generates embeddings for similarity search
- Implements extractive summarization
- Manages content storage and retrieval
- Integrates with vector store for search

### Vector Store Integration (../vector_store/core/types.ts)
- Provides vector storage and search capabilities
- Supports multiple distance metrics
- Implements caching strategies
- Handles metadata management
- Enables efficient similarity search

## Setup

1. Install dependencies:
```bash
cd /Volumes/mattstack/VSCode/AeonNovaFutureLabs/ai_components/scraper
npm install
```

2. Build TypeScript:
```bash
npm run build
```

3. Run tests:
```bash
npm test
```

## Usage

### As MCP Server

```typescript
import { ChatScraperServer } from './250208_CHAT_SCRAPER_INT_v1.0_ANFL';

const server = new ChatScraperServer();
server.run().catch(console.error);
```

Available tools:
- `scrape_claude`: Extract chat history from Claude
- `scrape_chatgpt`: Extract chat history from ChatGPT

### Metadata Processing

```typescript
import { ChatMetadataProcessor } from './250208_METADATA_PROCESSOR_INT_v1.0_ANFL';
import { VectorStore } from '../vector_store/core/types';

const vectorStore = new VectorStore({
  dimension: 1536,
  metric: 'cosine'
});

const processor = new ChatMetadataProcessor(vectorStore);

// Process chat data
const processed = await processor.processChatData(chatData);

// Search similar chats
const similar = await processor.searchSimilar('query text');

// Retrieve content
const content = await processor.retrieveContent(metadata);
```

## Features

- Framework-compliant implementation
- Non-destructive operations
- Efficient metadata storage
- Vector-based similarity search
- Extractive summarization
- Topic extraction
- Key points identification
- Content hashing and versioning
- Structured data organization

## Security

- Confidential security level
- Secure content storage
- Access control through MCP
- Authentication handling
- Data validation and sanitization

## Testing

Run the test script to verify functionality:

```typescript
import { testScraper } from './test_scraper';

testScraper().catch(console.error);
```

The test script verifies:
- Chat data processing
- Metadata extraction
- Vector storage
- Similarity search
- Content retrieval

## References

- 250208_ARCH_OVERVIEW_INT_v1.0_ANFL.md
- intelligent-indexer.py
- MCP SDK documentation