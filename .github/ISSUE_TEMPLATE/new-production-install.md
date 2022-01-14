---
name: New Production Install
about: Document a new target install scenario for a single end user
title: 'New Installation: [CUSTOMER]'
labels: project::new-production-install
assignees: ''

---

### Intro, use case, impact, and target go-live date
<!-- Describe the customer and their use case or value prop. If possible, add any notes on the priority / strategic impact of getting this customer successfully up and running. -->



### Definition of Success
<!-- Define what "success" looks like for this end user, beyond just "getting the software up and running" -->


### Team

- [ ] Vendor Technical Leads: 
- [ ] Vendor Business Leads:
- [ ] Replicated Technical Leads:
- [ ] Replicated Business Leads:

### Timeline and Next Steps
<!-- Area to Track past engagements as well as next steps. Example provided below:

11/1 Customer working to provision new machine with bigger disk, next attempt 11/3

10/29 Initial installation call, app up and running but ran out of disk space and fell over. Replicated team recommends resolving issue [#10 -- preflight checks for disk space]() before next attempt.

10/27 Pre-Planning call with Replicated team, task list reviewed and validated

10/20 Customer identified as potential prospect, PoC kick off scheduled for 10/29

 -->


### Additional Tasks Required to Prepare for this installation
<!-- Can include integration work (from “production ready” board), testing work, documentation work, planning calls or anything else -->

- [ ] Discovery: [Outline Environment](#environment)
- [ ] Schedule Installation Date: 
- [ ] Pre-install huddle with Replicated CS team and Replicated Engineering Support
- [ ] … etc


### Environment
<!-- Describe the customer’s environment-->

Install type:
<!-- Is this an Embedded or Existing Cluster? -->

Airgap:
<!-- Is this an Airgapped and/or BYO Registry installation? -->

Operating System (if embedded):
<!-- Red Hat  -->


Cluster Flavor (if existing):

Ingress Strategy:
<!-- How will the end user interact with the application and with the app manager UI? Will there be a load balancer in front of a VM? Do they have an existing ingress or service mesh controller that must be used? Do any services require Node Ports? -->

Datacenter:
<!-- Is this AWS? Bare Metal? VSphere? GCP? Azure? Something else? -->

Additional Details:
