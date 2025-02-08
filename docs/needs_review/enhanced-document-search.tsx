import React, { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Search, FileText, AlertCircle } from 'lucide-react';
import axios from 'axios';

interface SearchResult {
  title: string;
  summary: string;
  score: number;
}

const DocumentSearch: React.FC = () => {
  const [query, setQuery] = useState<string>('');
  const [searchResults, setSearchResults] = useState<SearchResult[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const handleSearch = async () => {
    if (!query.trim()) return;
    
    setIsLoading(true);
    setError(null);
    
    try {
      const response = await axios.get(`http://localhost:5000/search?q=${query}`);
      setSearchResults(response.data);
    } catch (error) {
      setError('Error searching documents. Please try again.');
      console.error('Error searching documents:', error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <Card gradient="primary" className="w-full max-w-4xl mx-auto">
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Search className="w-6 h-6" />
            Document Search
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex gap-4">
            <input
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="Enter search query"
              className="flex-1 px-4 py-2 rounded-lg border border-[#CD7F32]/20 
                       bg-gradient-to-r from-[#1A1A2E] to-[#33334C] 
                       text-white placeholder-gray-400 focus:outline-none 
                       focus:ring-2 focus:ring-[#CD7F32]/50"
              onKeyPress={(e) => e.key === 'Enter' && handleSearch()}
            />
            <button
              onClick={handleSearch}
              disabled={isLoading}
              className="px-6 py-2 rounded-lg bg-gradient-to-r 
                       from-[#CD7F32] to-[#DBA867] text-white 
                       font-medium hover:from-[#DBA867] hover:to-[#CD7F32] 
                       transition-all duration-300 disabled:opacity-50"
            >
              {isLoading ? 'Searching...' : 'Search'}
            </button>
          </div>

          {error && (
            <div className="mt-4 p-4 rounded-lg bg-red-500/10 border 
                          border-red-500/20 text-red-500 flex items-center gap-2">
              <AlertCircle className="w-5 h-5" />
              {error}
            </div>
          )}

          <div className="mt-6 space-y-4">
            {searchResults.map((doc, index) => (
              <Card
                key={index}
                gradient="secondary"
                className="hover:shadow-lg transition-all duration-300"
              >
                <CardContent className="p-4">
                  <div className="flex items-start gap-3">
                    <FileText className="w-5 h-5 text-[#CD7F32] mt-1" />
                    <div>
                      <h4 className="font-medium text-lg text-white">
                        {doc.title}
                      </h4>
                      <p className="mt-1 text-gray-300">
                        {doc.summary}
                      </p>
                      <div className="mt-2">
                        <span className="inline-flex items-center px-2.5 py-0.5 
                                     rounded-full text-xs font-medium 
                                     bg-[#CD7F32]/20 text-[#DBA867]">
                          Score: {doc.score.toFixed(2)}
                        </span>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>

          {searchResults.length === 0 && !isLoading && query && !error && (
            <div className="mt-4 text-center text-gray-400">
              No results found. Try a different search term.
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
};

export default DocumentSearch;