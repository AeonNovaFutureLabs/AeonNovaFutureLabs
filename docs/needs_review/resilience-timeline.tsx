import React from 'react';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Calendar, Shield, Database, Cloud, Activity } from 'lucide-react';

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

const ResilienceTimeline = () => {
  const phases = [
    {
      phase: "Multi-Region Setup",
      timeline: "Q1 2024",
      icon: Cloud,
      items: [
        "Astra DB multi-region configuration",
        "Document processor regional deployment",
        "CDN integration",
        "Cross-region networking"
      ]
    },
    {
      phase: "Resilience Implementation",
      timeline: "Q2 2024",
      icon: Shield,
      items: [
        "Chaos engineering framework setup",
        "Automatic failover configuration",
        "Load balancing implementation",
        "Disaster recovery procedures"
      ]
    },
    {
      phase: "Storage Optimization",
      timeline: "Q2 2024",
      icon: Database,
      items: [
        "Redis cache layer deployment",
        "Backup strategy implementation",
        "Data replication setup",
        "Storage monitoring"
      ]
    },
    {
      phase: "Performance Monitoring",
      timeline: "Q3 2024",
      icon: Activity,
      items: [
        "Prometheus metrics configuration",
        "Grafana dashboard setup",
        "Alert system implementation",
        "Performance optimization"
      ]
    }
  ];

  return (
    <Card className="w-full max-w-4xl">
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Calendar className="w-6 h-6" />
          Aeon Nova Resilience Implementation Timeline
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

export default ResilienceTimeline;