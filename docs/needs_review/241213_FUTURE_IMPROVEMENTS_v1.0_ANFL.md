# Future Improvements & Known Gaps

## Known Gaps
1. **Developer Onboarding**: While the getting_started.md doc helps, we could add a “Hello World” style tutorial walking new developers through deploying a simple model or running a test inference.
2. **Integration Tests**: DEV_INTEGRATION_INT doc mentions integration patterns but lacks detailed integration testing scenarios. Adding examples of end-to-end tests would strengthen reliability.
3. **Security Roadmap**: Security docs are robust, but a roadmap outlining future steps (e.g., planned algorithm migrations or next PQC milestones) would provide clarity.

## Potential Enhancements
1. **User Journeys**: Add user stories or example scenarios (e.g., how a data scientist updates a model or how ops respond to a failover event) to bridge the gap between theory and practice.
2. **More Visuals**: Additional sequence diagrams or architecture maps for complex flows (e.g., how backups and restores are handled across multi-region infra).
3. **Performance Benchmarks**: Include baseline performance metrics and expected SLAs for response times, throughput, and resource usage to guide optimization efforts.

## Process for Updates
- Propose changes in a Git branch referencing the doc needing enhancement.
- Conduct a short review cycle with relevant stakeholders (e.g., Security Lead, ML Lead).
- Merge and update `doc_plan_status.md` to reflect the new changes.
