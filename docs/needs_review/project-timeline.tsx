import React from 'react';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Calendar, GitBranch, Database, Brain, Activity } from 'lucide-react';

const TimelineItem = ({ phase, timeline, items, icon: Icon }) => (
  <div className="mb-8">
    <div className="flex items-center mb-2">
      <div className="p-2 rounded-full bg-blue-100 mr-2">
        <Icon className="w-5 h-5 text-blue-600" />
      </div>
      <h3 className="text-lg font-semibold">{phase}</h3>
      <Badge variant="secondary" className="ml-2">{timeline}</Badge>
    </div>
    <div className="pl-12">
      {items.map((item, index) => (
        <div key={index} className="mb-2 flex items-start">
          <div className="w-2 h-2 rounded-full bg-gray-400 mt-2 mr-2"></div>
          <span>{item}</span>
        </div>
      ))}
    </div>
  </div>
);

const ProjectTimeline = () => {
  const phases = [
    {
      phase: "Infrastructure Setup",
      timeline: "Q1 2024",
      icon: GitBranch,
      items: [
        "GitLab repository and K8s agent setup",
        "Local Kubernetes cluster configuration",
        "Project structure and CI/CD pipeline",
        "Security implementations"
      ]
    },
    {
      phase: "Data Architecture",
      timeline: "Q1-Q2 2024",
      icon: Database,
      items: [
        "Astra DB schema implementation",
        "Data processing pipeline setup",
        "Vector store integration",
        "Caching layer configuration"
      ]
    },
    {
      phase: "AI Integration",
      timeline: "Q2 2024",
      icon: Brain,
      items: [
        "LangChain framework implementation",
        "Federated learning setup",
        "RAG pipeline development",
        "Meta-learning systems integration"
      ]
    },
    {
      phase: "Monitoring & Optimization",
      timeline: "Q2-Q3 2024",
      icon: Activity,
      items: [
        "Prometheus & Grafana setup",
        "Performance metrics collection",
        "Resource optimization",
        "Production environment configuration"
      ]
    }
  ];

  return (
    <Card className="w-full max-w-4xl">
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Calendar className="w-6 h-6" />
          Aeon Nova AI Implementation Timeline
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div className="mt-4">
          {phases.map((phase, index) => (
            <TimelineItem key={index} {...phase} />
          ))}
        </div>
      </CardContent>
    </Card>
  );
};

export default ProjectTimeline;import { Card, CardHeader, CardTitle, CardContent } from './ui/card';
import { Badge } from './ui/badge';