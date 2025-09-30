# Red Hat Software Collections (RHSCL) and Modern Supply Chain Security

Red Hat Software Collections (RHSCL) was a Red Hat offering that provided developers with the latest stable versions of a wide range of development tools, dynamic languages, and open-source databases for Red Hat Enterprise Linux (RHEL).

## What was Red Hat Software Collections?

RHSCL allowed developers to work with newer software versions than those included in the base RHEL system. A key feature was the ability to install and use multiple versions of the same software concurrently without affecting the system's default packages. This was achieved by installing the collection's packages in the `/opt/` directory, preventing conflicts with the base system tools.

Benefits of RHSCL included:
*   **Access to recent software versions:** Developers could use the latest features in languages like Python, PHP, Ruby, and Node.js, as well as databases such as MongoDB, MariaDB, and PostgreSQL.
*   **Stability and support:** RHSCL provided a stable and supported environment with a support lifecycle of two to three years for each collection.
*   **Container-friendly:** Many collections were available as container images.

## How did RHSCL help with Supply Chain Security?

RHSCL provided a degree of supply chain security by:

*   **Providing a trusted source:** The software collections were provided and signed by Red Hat, ensuring they came from a trusted source.
*   **Security Advisories:** Red Hat issued Critical and Important Security Errata Advisories (RHSAs) and Urgent Priority Bug Fix Errata Advisories (RHBAs) for the collections.
*   **Defined Lifecycle:** Each collection had a defined support lifecycle, so users knew for how long security updates would be provided.

## The Evolution to Application Streams and Red Hat Trusted Software Supply Chain

Starting with RHEL 8, the content traditionally delivered via Software Collections is now part of **Application Streams**.

For a more comprehensive and modern approach to software supply chain security, Red Hat has introduced the **Red Hat Trusted Software Supply Chain**. This solution integrates security into every phase of the software development lifecycle (SDLC).

### Components of the Red Hat Trusted Software Supply Chain:

*   **Red Hat Trusted Content:** A curated catalog of trusted and signed open-source software packages.
*   **Red Hat Trusted Application Pipeline:** A security-focused CI/CD service for containerized applications.
*   **Red Hat Trusted Artifact Signer:** Allows developers to cryptographically sign and verify software artifacts.
*   **Red Hat Trusted Profile Analyzer:** A tool for managing and analyzing Software Bill of Materials (SBOMs) and Vulnerability Exploitability Exchange (VEX) documents.
*   **Red Hat Advanced Cluster Security for Kubernetes (ACS):** Provides Kubernetes-native security features.
*   **Red Hat Quay:** A security-focused, scalable private container registry.

## How to Get Started

### Using Red Hat Software Collections (RHEL 7 and earlier)

To use a specific collection, you can use the `scl` utility to enable it. This creates a new shell environment with the necessary environment variables updated.

```bash
# To enable a software collection
scl enable <collection_name> bash
```

### Engaging with the Red Hat Trusted Software Supply Chain

The Red Hat Trusted Software Supply Chain is a comprehensive solution that is layered onto application platforms like Red Hat OpenShift. To get started, you would typically:

1.  **Use Red Hat OpenShift:** as your Kubernetes platform.
2.  **Integrate Red Hat Trusted Content:** into your development process.
3.  **Implement Red Hat Trusted Application Pipeline:** for secure CI/CD.
4.  **Utilize Red Hat Advanced Cluster Security (ACS):** to secure your Kubernetes environment.

