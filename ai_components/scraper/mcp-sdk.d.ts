// ----------------------------------------------------------------------------
// File: mcp-sdk.d.ts
// Location: /Volumes/mattstack/VSCode/AeonNovaFutureLabs/ai_components/scraper/
//
// Purpose: Type definitions for MCP SDK
// Security Level: Confidential
// Owner: Infrastructure Team
// Version: 1.0
// Last Modified: 2025-02-08
// ----------------------------------------------------------------------------

declare module '@modelcontextprotocol/sdk/server' {
  import { Request, ToolResponse } from '@modelcontextprotocol/sdk/types';
  
  export class Server {
    constructor(
      info: {
        name: string;
        version: string;
      },
      config: {
        capabilities: {
          tools?: Record<string, unknown>;
          resources?: Record<string, unknown>;
        };
      }
    );

    onerror: (error: Error) => void;
    setRequestHandler: {
      <TArgs = unknown, TResponse = unknown>(
        schema: unknown,
        handler: (request: Request<TArgs>) => Promise<TResponse>
      ): void;
    };
    connect: (transport: unknown) => Promise<void>;
    close: () => Promise<void>;
  }
}

declare module '@modelcontextprotocol/sdk/server/stdio' {
  export class StdioServerTransport {
    constructor();
  }
}

declare module '@modelcontextprotocol/sdk/types' {
  export enum ErrorCode {
    InvalidRequest = 'InvalidRequest',
    MethodNotFound = 'MethodNotFound',
    InternalError = 'InternalError'
  }

  export class McpError extends Error {
    constructor(code: ErrorCode, message: string);
    code: ErrorCode;
  }

  export interface Request<T = unknown> {
    params?: {
      name?: string;
      arguments?: T;
    };
  }

  export interface ToolResponse {
    content: Array<{
      type: string;
      text: string;
    }>;
  }

  export const CallToolRequestSchema: unique symbol;
  export const ListToolsRequestSchema: unique symbol;
}