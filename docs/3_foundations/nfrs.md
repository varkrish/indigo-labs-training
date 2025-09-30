# Overview

In addition to functional requirements—which specify what a system should do—software systems must also meet a set of **non-functional requirements (NFRs)**. These requirements define how a system should behave and set criteria for evaluating the operation of a system, rather than specific behaviors or features.

Non-functional requirements are critical for ensuring that applications are reliable, scalable, secure, and maintainable. They often influence architectural decisions and can have a significant impact on user satisfaction and system success.

## What Are Non-Functional Requirements?

Non-functional requirements describe the quality attributes, system properties, and constraints that a solution must have. They answer questions such as:

- How fast should the system respond? (Performance)
- How many users should it support? (Scalability)
- How often can it be unavailable? (Availability)
- How secure must it be? (Security)
- How easy is it to maintain or extend? (Maintainability)
- How well does it recover from failures? (Reliability)
- How easy is it to use? (Usability)
- How portable is it across environments? (Portability)
- How well does it support monitoring and troubleshooting? (Observability)

## Common Categories of NFRs

| Category         | Description                                                                 |
|------------------|-----------------------------------------------------------------------------|
| **Performance**  | Response time, throughput, latency, resource usage                          |
| **Scalability**  | Ability to handle increased load or users                                   |
| **Availability** | Uptime requirements, fault tolerance, disaster recovery                     |
| **Reliability**  | Consistency of correct operation over time                                  |
| **Security**     | Authentication, authorization, data protection, compliance                  |
| **Maintainability** | Ease of updates, bug fixes, and enhancements                             |
| **Usability**    | User experience, accessibility, learnability                                |
| **Portability**  | Ability to run on different platforms or environments                       |
| **Observability**| Logging, monitoring, tracing, and diagnostics                               |
| **Compliance**   | Adherence to legal, regulatory, or industry standards                       |

## Why NFRs Matter

Neglecting non-functional requirements can lead to systems that technically work, but fail to meet user or business expectations. For example, an application may provide all required features but be too slow, unreliable, or difficult to maintain. NFRs help ensure that the system is robust, efficient, and ready for real-world use.

## NFRs in Modern Application Development

When building cloud-native, containerized, or microservices-based applications, NFRs become even more important. For example:

- **Performance and scalability** must be considered for distributed workloads.
- **Security** is critical in multi-tenant and public cloud environments.
- **Observability** enables effective monitoring and troubleshooting in dynamic, ephemeral infrastructure.
- **Availability and reliability** are essential for always-on services.

## Best Practices

- **Define NFRs early:** Capture them alongside functional requirements.
- **Make NFRs measurable:** Use specific, testable criteria (e.g., "99.9% uptime," "response time < 200ms").
- **Prioritize NFRs:** Not all NFRs are equally important—focus on those most critical to your stakeholders.
- **Validate and test:** Use automated tests, monitoring, and reviews to ensure NFRs are met.
- **Iterate:** Revisit NFRs as the system evolves and as usage patterns change.

## Further Reading

- [Red Hat: Non-functional requirements for cloud-native applications](https://developers.redhat.com/articles/2021/09/15/non-functional-requirements-cloud-native)
- [OWASP: Security Requirements](https://owasp.org/www-project-security-knowledge-framework/)
- [Martin Fowler: Non-Functional Requirements](https://martinfowler.com/bliki/NonFunctionalRequirement.html)

By carefully considering and implementing non-functional requirements, you can build software that not only works, but excels in real-world environments.