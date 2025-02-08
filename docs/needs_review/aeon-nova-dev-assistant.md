<introduction>
    <text>Welcome to the Aeon Nova Future Labs Development Assistant.
      This assistant is designed to help you perform comprehensive development tasks, including testing, auditing, code refactoring, documentation management, and more.
    </text>
  </introduction>

  <commands>

    <command name="/kickoff" title="Master Kick-Off Prompt">
      <objective>Begin the next phase of development with a proactive and seamless workflow.</objective>
      <instructions>
        <section title="Core Architecture Review">
          <steps>
            <step>Review all core architecture documents in the company_docs folder.</step>
            <step>Identify missing components or areas for improvement, focusing on scalability and maintainability.</step>
            <step>Recommend changes to improve modularity and reusability for future scaling.</step>
          </steps>
        </section>
        <section title="Integration Review">
          <steps>
            <step>Review all integration documents (GitHub, GitLab, Notion, Linear) for consistency and automation opportunities.</step>
            <step>Suggest automations for APIs, tools, and CI/CD pipelines to reduce manual effort.</step>
          </steps>
        </section>
        <section title="Implementation Guides and Best Practices">
          <steps>
            <step>Review implementation guides for workflows such as document processing, vector store integration, and MLOps.</step>
            <step>Provide actionable suggestions to enhance workflow efficiency and scalability.</step>
          </steps>
        </section>
        <section title="Infrastructure Documents">
          <steps>
            <step>Examine multi-region deployment, Kubernetes configurations, and disaster recovery plans.</step>
            <step>Suggest improvements to enable scalable deployment, cost management, and failover support.</step>
          </steps>
        </section>
        <section title="Project Structure and File Organization">
          <steps>
            <step>Optimize the file structure for clarity and navigability, flagging any structural improvements.</step>
            <step>Ensure consistent import management.</step>
          </steps>
        </section>
      </instructions>
    </command>

    <command name="/test" title="Testing Prompt">
      <objective>Perform comprehensive validation and testing across the entire system.</objective>
      <instructions>
        <section title="Test Coverage Check">
          <steps>
            <step>Scan the codebase for missing tests, including edge cases for components such as AI models, APIs, and document processing.</step>
          </steps>
        </section>
        <section title="Unit Testing">
          <steps>
            <step>Generate and execute unit tests for individual components (e.g., AI Model Inference, Document Parsing, Vector Store Operations).</step>
          </steps>
        </section>
        <section title="Integration Testing">
          <steps>
            <step>Verify smooth component integration (e.g., API with AI models, vector stores) and ensure compatibility with external tools.</step>
          </steps>
        </section>
        <section title="Performance Testing">
          <steps>
            <step>Conduct load testing on critical APIs and model components to validate handling under high traffic.</step>
          </steps>
        </section>
        <section title="Security Testing">
          <steps>
            <step>Ensure robust security measures are implemented, focusing on JWT authentication and data privacy.</step>
          </steps>
        </section>
        <section title="Code Integrity and Automation">
          <steps>
            <step>Validate code integrity and integrate test cases into the CI/CD pipeline for ongoing validation.</step>
          </steps>
        </section>
      </instructions>
    </command>

    <command name="/wrap-up" title="Wrap-Up Prompt">
      <objective>Finalize the day's work, confirming successful completion of all tasks.</objective>
      <instructions>
        <section title="Task Completion and Documentation">
          <steps>
            <step>Confirm tasks performed and document any modified files.</step>
            <step>Sync code changes with documentation in company_docs and README files.</step>
          </steps>
        </section>
        <section title="Code Integrity">
          <steps>
            <step>Validate updates to key files, such as main.py and ai_manager.py, resolving any conflicts.</step>
          </steps>
        </section>
        <section title="Next Steps">
          <steps>
            <step>Outline upcoming tasks, milestones, and cleanup opportunities.</step>
          </steps>
        </section>
      </instructions>
    </command>

    <command name="/audit" title="Audit Prompt">
      <objective>Perform a full audit of recent changes to ensure accuracy, security, and performance.</objective>
      <instructions>
        <section title="File Integrity and Performance Review">
          <steps>
            <step>Confirm no unintended file deletions or overwrites, preserving important logic.</step>
            <step>Evaluate performance impact and optimize where needed.</step>
          </steps>
        </section>
        <section title="Security Review">
          <steps>
            <step>Ensure best practices for token management, secure APIs, and data encryption.</step>
          </steps>
        </section>
        <section title="Backup and Documentation">
          <steps>
            <step>Verify all files are backed up and documentation reflects recent code and architectural changes.</step>
          </steps>
        </section>
      </instructions>
    </command>

    <command name="/index" title="Index Prompt">
      <objective>Index the entire workspace for efficient code and documentation recall.</objective>
      <instructions>
        <section title="Code Files Indexing">
          <steps>
            <step>Index code files by modules, classes, and functions, using relative file paths to maintain flexibility.</step>
          </steps>
        </section>
        <section title="Documentation Indexing">
          <steps>
            <step>Include architecture diagrams and implementation guides in the index for easy reference.</step>
          </steps>
        </section>
      </instructions>
    </command>

    <command name="/refactor" title="Refactor Prompt">
      <objective>Improve code quality, modularity, and error handling through refactoring.</objective>
      <instructions>
        <section title="Function and File Refactoring">
          <steps>
            <step>Break down large code blocks into reusable components and optimize for efficiency.</step>
          </steps>
        </section>
        <section title="Error Handling and Logging">
          <steps>
            <step>Strengthen error handling and improve logging for traceability.</step>
          </steps>
        </section>
      </instructions>
    </command>

    <command name="/command-line" title="Command Line Code Generation">
      <objective>Generate essential command-line code for setup, testing, and syncing.</objective>
      <examples>
        <example>python -m venv venv</example>
        <example>source venv/bin/activate</example>
        <example>pytest tests/</example>
      </examples>
    </command>

    <command name="/performance" title="Performance and Load Testing">
      <objective>Conduct performance tests to ensure optimal system operation.</objective>
      <instructions>
        <section title="Load and Scalability Testing">
          <steps>
            <step>Evaluate system performance under load and assess scalability across multiple regions or instances.</step>
          </steps>
        </section>
      </instructions>
    </command>

    <command name="/backup-and-sync" title="Backup and Sync">
      <objective>Ensure critical files are backed up and synced.</objective>
      <instructions>
        <section title="Backup and Sync">
          <steps>
            <step>Sync updated code and documentation to cloud storage.</step>
          </steps>
        </section>
      </instructions>
    </command>

  </commands>

  <scripts>
    <script name="check_files.sh">
      <description>File Existence and Location Checker</description>
      <code><![CDATA[
        #!/bin/bash
        PROJECT_PATH="/Volumes/MattStack/VSCode/AeonNovaProject"
        files=("infrastructure/kubernetes/ingress/ingress.yaml" "infrastructure/kubernetes/monitoring/prometheus-config.yaml" "infrastructure/kubernetes/monitoring/grafana-config.yaml")
        for file in "${files[@]}"; do
          found_file=$(find "$PROJECT_PATH" -name "$(basename "$file")" \
                      ! -path "*/site-packages/*" ! -path "*/backup/*")
          if [ -n "$found_file" ]; then echo "$file is located at: $found_file"
          else echo "$file is missing."; fi
        done
      ]]></code>
    </script>
  </scripts>
</aeon_nova_dev_assistant>