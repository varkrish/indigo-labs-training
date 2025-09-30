Leveraging vendor specific cloud features may lead to:

- Increased difficulty in migrating workloads to other cloud providers
- Higher long-term costs due to lack of competition or pricing flexibility
- Limited portability and interoperability of applications
- Greater dependency on a single vendor’s roadmap and support
- Potential compliance or data residency challenges if features are not available in all regions

By being aware of these risks, organizations can make more informed decisions about when and how to use proprietary cloud features, and consider hybrid or multi-cloud strategies to maintain flexibility and control.
* **Dependency on provider roadmap**: Changes or discontinuation of services by the provider can disrupt business operations.
* **Compliance and data residency issues**: Some features may not be available in all regions, impacting regulatory compliance.
* **Potential for higher long-term costs**: Initial incentives may give way to higher ongoing expenses as workloads grow.



## Hybrid Cloud Approach

In a hybrid cloud strategy we aim to combine on-premises infrastructure, private cloud, and public cloud services to create a unified, consitent flexible computing environment. This approach allows organizations to:

- Avoid vendor lock-in by designing applications for portability and interoperability.
- Meet regulatory or data residency requirements by keeping sensitive workloads on-premises or in private clouds.
- Optimize costs by running workloads in the most appropriate environment.
- Enhance resilience and business continuity by distributing workloads across multiple platforms.
- Reuse the code across multiple vendor solutions.

**Advantages of a Hybrid Cloud Approach:**

- Enables the use of open standards and cloud-agnostic tools (such as Kubernetes and Terraform) for consistent infrastructure management.
- Increases application portability by minimizing reliance on proprietary services, making it easier to move workloads between environments.
- Enhances security and connectivity through robust networking and security controls across on-premises, private, and public clouds.
- Provides unified monitoring and management of resources, helping optimize cost, performance, and compliance across all environments.

### Real world example
#### Example: Unified CI/CD with Tekton Across Hybrid Cloud Providers

In a hybrid cloud environment, organizations often use different CI/CD solutions depending on where their code is hosted or deployed. For example, you might use:

- **GitLab CI** for projects hosted on GitLab (on-premises or cloud)
- **GitHub Actions** for repositories on GitHub
- **Tekton/OpenShift Pipelines** for cloud-native, Kubernetes-based deployments

**Challenge:**  
Each of these CI/CD systems has its own configuration syntax and pipeline definitions. This means that if you move your code or workloads between providers (e.g., from GitHub to GitLab, or from on-premises to the cloud), you often have to rewrite your CI/CD pipeline code to fit the new system.

**Solution with Tekton:**  
Tekton is a cloud-native, Kubernetes-based CI/CD solution that uses standard Kubernetes resources to define pipelines. By adopting Tekton, you can write your pipeline definitions once and run them anywhere Kubernetes is available—on-premises, in the public cloud, or in a hybrid environment—without changing your pipeline code.