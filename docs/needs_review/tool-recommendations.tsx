import React from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { 
  Settings, 
  Code2, 
  Database, 
  Cloud, 
  BarChart, 
  Wrench,
  Terminal,
  Layout
} from 'lucide-react';

const ToolCategory = ({ title, tools }) => (
  <div className="mb-8">
    <div className="flex items-center mb-4">
      <Wrench className="w-5 h-5 mr-2 text-blue-600" />
      <h3 className="text-lg font-semibold">{title}</h3>
    </div>
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
      {tools.map((tool, index) => (
        <Card key={index} className="bg-white">
          <CardContent className="pt-4">
            <div className="flex items-start">
              <div className="p-2 rounded-full bg-blue-100 mr-3">
                {React.createElement(tool.icon, { 
                  className: "w-4 h-4 text-blue-600" 
                })}
              </div>
              <div>
                <h4 className="font-medium">{tool.name}</h4>
                <p className="text-sm text-gray-600 mt-1">{tool.description}</p>
                <div className="mt-2 space-x-2">
                  {tool.tags.map((tag, i) => (
                    <Badge key={i} variant="secondary">{tag}</Badge>
                  ))}
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      ))}
    </div>
  </div>
);

const ToolRecommendations = () => {
  const recommendations = {
    "Development Tools": [
      {
        name: "Insomnia",
        description: "API development and testing tool - great for testing Linear, Notion, and other API integrations",
        icon: Code2,
        tags: ["API", "Testing", "Development"]
      },
      {
        name: "MongoDB Compass",
        description: "GUI for MongoDB - useful for database visualization and management",
        icon: Database,
        tags: ["Database", "GUI", "Development"]
      }
    ],
    "Cloud & Infrastructure": [
      {
        name: "Terraform",
        description: "Infrastructure as Code tool for managing cloud resources",
        icon: Cloud,
        tags: ["IaC", "Cloud", "DevOps"]
      },
      {
        name: "K9s",
        description: "Terminal UI for managing Kubernetes clusters",
        icon: Terminal,
        tags: ["Kubernetes", "CLI", "DevOps"]
      }
    ],
    "Productivity Tools": [
      {
        name: "Rectangle",
        description: "Window management tool for macOS",
        icon: Layout,
        tags: ["Productivity", "macOS"]
      },
      {
        name: "Fig",
        description: "Terminal autocomplete and IDE-style features",
        icon: Terminal,
        tags: ["Terminal", "Productivity"]
      }
    ],
    "Monitoring & Analytics": [
      {
        name: "Grafana",
        description: "Analytics and monitoring solution",
        icon: BarChart,
        tags: ["Monitoring", "Analytics", "DevOps"]
      },
      {
        name: "Datadog",
        description: "Cloud monitoring and analytics platform",
        icon: Settings,
        tags: ["Monitoring", "Cloud", "Analytics"]
      }
    ]
  };

  return (
    <Card className="w-full max-w-4xl">
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Wrench className="w-6 h-6" />
          Recommended Development Tools
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-6">
          {Object.entries(recommendations).map(([category, tools]) => (
            <ToolCategory key={category} title={category} tools={tools} />
          ))}
        </div>
      </CardContent>
    </Card>
  );
};

export default ToolRecommendations;