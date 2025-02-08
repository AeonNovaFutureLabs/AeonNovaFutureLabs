# Environment Configuration (.env file)

Save this as `.env` in your project root (/Volumes/MattStack/VSCode/AeonNovaProject/ai_components/.env):

```env
# Pinecone Configuration
PINECONE_API_KEY=your_pinecone_api_key_here
PINECONE_ENVIRONMENT=gcp-starter
PINECONE_INDEX=aeon-nova

# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key_here

# Optional Configuration
LOG_LEVEL=INFO
BATCH_SIZE=100
CHUNK_SIZE=1000
CHUNK_OVERLAP=200
```

Note: Replace `your_pinecone_api_key_here` and `your_openai_api_key_here` with your actual API keys.
For Pinecone environment, use your specific environment (e.g., 'gcp-starter' or 'us-west1-gcp-free').
