// ----------------------------------------------------------------------------
// File: 250208_CHAT_SCRAPER_INT_v1.0_ANFL.ts
// Location: /Volumes/mattstack/VSCode/AeonNovaFutureLabs/ai_components/scraper/
//
// Purpose: MCP server for scraping Claude and ChatGPT chat histories
// Security Level: Confidential
// Owner: Infrastructure Team
// Version: 1.0
// Last Modified: 2025-02-08
//
// References:
// - 250208_ARCH_OVERVIEW_INT_v1.0_ANFL.md
// - intelligent-indexer.py
// ----------------------------------------------------------------------------

import { Server } from '@modelcontextprotocol/sdk/server';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio';
import {
  CallToolRequestSchema,
  ErrorCode,
  ListToolsRequestSchema,
  McpError,
  Request,
  ToolResponse
} from '@modelcontextprotocol/sdk/types';
import * as puppeteer from 'puppeteer';
import { readFileSync } from 'fs';
import { join } from 'path';

interface ChatConfig {
  url: string;
  selectors: {
    chatList: string;
    chatItem: string;
    messageList: string;
    message: string;
    timestamp: string;
  };
}

interface ChatMessage {
  role: string;
  content: string;
  timestamp: string;
}

interface ChatHistory {
  id: string;
  title: string;
  messages: ChatMessage[];
  metadata: {
    source: string;
    scraped_at: string;
  };
}

interface ScrapeArgs {
  max_chats?: number;
  include_messages?: boolean;
}

class ChatScraperServer {
  private server: Server;
  private browser: puppeteer.Browser | null = null;
  private config: Record<string, ChatConfig> = {
    claude: {
      url: 'https://claude.ai',
      selectors: {
        chatList: '.conversation-list',
        chatItem: '.conversation-item',
        messageList: '.message-list',
        message: '.message-content',
        timestamp: '.message-timestamp'
      }
    },
    chatgpt: {
      url: 'https://chat.openai.com',
      selectors: {
        chatList: 'nav[data-testid="conversation-sidebar"]',
        chatItem: '[data-testid="conversation-item"]',
        messageList: '[data-testid="conversation-messages"]',
        message: '.markdown',
        timestamp: '.timestamp'
      }
    }
  };

  constructor() {
    this.server = new Server(
      {
        name: 'chat-scraper',
        version: '1.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.setupToolHandlers();
    
    // Error handling
    this.server.onerror = (error: Error) => console.error('[MCP Error]', error);
    process.on('SIGINT', async () => {
      await this.cleanup();
      process.exit(0);
    });
  }

  private setupToolHandlers(): void {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: [
        {
          name: 'scrape_claude',
          description: 'Scrape chat history from Claude',
          inputSchema: {
            type: 'object',
            properties: {
              max_chats: {
                type: 'number',
                description: 'Maximum number of chats to scrape',
                default: 10
              },
              include_messages: {
                type: 'boolean',
                description: 'Whether to include message content',
                default: true
              }
            }
          }
        },
        {
          name: 'scrape_chatgpt',
          description: 'Scrape chat history from ChatGPT',
          inputSchema: {
            type: 'object',
            properties: {
              max_chats: {
                type: 'number',
                description: 'Maximum number of chats to scrape',
                default: 10
              },
              include_messages: {
                type: 'boolean',
                description: 'Whether to include message content',
                default: true
              }
            }
          }
        }
      ]
    }));

    this.server.setRequestHandler<ToolResponse>(CallToolRequestSchema, async (request: Request<ScrapeArgs>) => {
      if (!request.params?.name) {
        throw new McpError(ErrorCode.InvalidRequest, 'Tool name is required');
      }

      switch (request.params.name) {
        case 'scrape_claude':
          return await this.scrapeChatHistory('claude', request.params.arguments || {});
        case 'scrape_chatgpt':
          return await this.scrapeChatHistory('chatgpt', request.params.arguments || {});
        default:
          throw new McpError(ErrorCode.MethodNotFound, `Unknown tool: ${request.params.name}`);
      }
    });
  }

  private async initBrowser(): Promise<puppeteer.Browser> {
    if (!this.browser) {
      this.browser = await puppeteer.launch({
        headless: true,
        args: ['--no-sandbox']
      });
    }
    return this.browser;
  }

  private async scrapeChatHistory(
    platform: 'claude' | 'chatgpt',
    args: ScrapeArgs
  ): Promise<ToolResponse> {
    try {
      const browser = await this.initBrowser();
      const page = await browser.newPage();
      const config = this.config[platform];

      // Navigate to platform
      await page.goto(config.url);

      // Wait for chat list
      await page.waitForSelector(config.selectors.chatList);

      // Get chat items
      const chats = await page.$$eval(
        config.selectors.chatItem,
        (elements: Element[], max: number) => elements.slice(0, max).map((el: Element) => ({
          id: el.getAttribute('data-conversation-id'),
          title: el.textContent?.trim()
        })),
        args.max_chats || 10
      );

      const histories: ChatHistory[] = [];

      // Scrape each chat
      for (const chat of chats) {
        if (!chat.id) continue;

        // Click chat item
        await page.click(`[data-conversation-id="${chat.id}"]`);
        await page.waitForSelector(config.selectors.messageList);

        let messages: ChatMessage[] = [];

        if (args.include_messages) {
          // Get messages
          messages = await page.$$eval(
            config.selectors.message,
            (elements: Element[], selectors: ChatConfig['selectors']) => elements.map((el: Element) => ({
              role: el.getAttribute('data-message-role') || 'unknown',
              content: el.textContent?.trim() || '',
              timestamp: el.querySelector(selectors.timestamp)?.textContent?.trim() || ''
            })),
            config.selectors
          );
        }

        histories.push({
          id: chat.id,
          title: chat.title || '',
          messages,
          metadata: {
            source: platform,
            scraped_at: new Date().toISOString()
          }
        });
      }

      return {
        content: [
          {
            type: 'text',
            text: JSON.stringify(histories, null, 2)
          }
        ]
      };

    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      throw new McpError(
        ErrorCode.InternalError,
        `Failed to scrape ${platform}: ${errorMessage}`
      );
    }
  }

  private async cleanup(): Promise<void> {
    if (this.browser) {
      await this.browser.close();
      this.browser = null;
    }
  }

  async run(): Promise<void> {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('Chat scraper MCP server running on stdio');
  }
}

const server = new ChatScraperServer();
server.run().catch(console.error);