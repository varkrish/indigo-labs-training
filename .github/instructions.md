# Documentation Instructions for Modern Software Development Practices

This repository contains comprehensive documentation for modern software development practices targeting **junior and mid-senior developers** working with **.NET and React Native applications**. All examples and practices should use **Podman/podman compose ** and **Red Hat UBI (Universal Base Images)**.

## 🎯 Target Audience

- **Junior developers** (0-3 years experience) learning modern development practices
- **Mid-senior developers** (3-7 years experience) adopting cloud-native and agile methodologies
- **Primary technologies**: .NET (C#) and React Native
- **Containerization**: Podman and podman compose  only
- **Base images**: Red Hat UBI images exclusively

## 📁 Documentation Structure Overview

The documentation is organized into the following main categories:

### 1. Cloud Fundamentals (`docs/1. cloud/`)

- **1.1 hybrid_cloud.md** - Hybrid cloud concepts and strategies
- **cloud_native_development.md** - Cloud-native development principles
- **cncf.md** - Cloud Native Computing Foundation landscape

### 2. Containerization (`docs/2. containerization/`)

- **2.1 containers.md** - Container fundamentals with Podman
- **2.2 container_engines_crio.md** - CRI-O container engine
- **2.3k8s_openshift.md** - Kubernetes and OpenShift concepts

### 3. Development Foundations (`docs/3. Agile and Cloud Native Dev foundations/`)

- **1. requirement_centric_development.md** - Requirements-driven development
- **2. 12-factor-app copy.md** - 12-factor app methodology
- **3. microservices.md** - Microservices architecture
- **4. open_practices_inner_loop.md** - Developer inner loop practices
- **5. open_practices_outer_loop.md** - DevOps outer loop practices
- **6. nfrs.md** - Non-functional requirements

### 4. Agile Development & Testing (`docs/4. Agile Development and Testing/`)

- **4.0 clean_architecture.md** - Clean architecture principles
- **4.1. bdd_tdd.md** - BDD and TDD practices
- **4.2 using_composefilesforlocaldev.md** - Local development with podman compose 
- **4.3 mocking_dependent_systems_apis.md** - API mocking strategies
- **4.4 secure_coding.md** - Secure coding practices
- **4.5 performance_testing_containers.md** - Performance testing in containers

### 5. CI/CD (`docs/ci_cd/`)

- **cloud_native_ci_cd.md** - Cloud-native CI/CD pipelines

### 6. Observability (`docs/observability/`)

- **dotnet_open_telementry.md** - OpenTelemetry in .NET

### 7. Red Hat Ecosystem (`docs/redhat_ecosystem/`)

- **redhat_software_collections.md** - Red Hat Software Collections
- **redhat_supply_chain_ubi.md** - UBI images and supply chain security

## ✍️ Writing Guidelines

### Content Structure

Each documentation file should follow this structure:

```markdown
# [Topic Title]

## Overview
Brief description of the topic and why it matters for junior/mid-senior developers.

## Key Concepts
- Fundamental concepts explained in practical terms
- Explain historical signifcance if appliable 
- Use simple scenario based story telling approach
- Relevant for .NET and React Native development
- Use book like "style"

## Prerequisites
- Knowledge requirements
- Tools needed (Podman, etc.)

## Practical Examples
### Example 1: [Scenario]
[Step-by-step example using .NET or React Native with Podman/UBI]

### Example 2: [Scenario]
[Another practical example]

## Common Pitfalls
- Issues junior developers commonly face
- How to avoid them

## Best Practices
- Industry-standard practices
- Team collaboration tips

## Tools and Resources
- Recommended tools
- Further reading
- Useful links

## Hands-on Exercise
Practical exercise for readers to try

## Summary
Key takeaways
```

### Technical Requirements

#### Container Examples

- **Always use Podman** instead of Docker
- **Use podman compose ** instead of Docker Compose
- **Base images must be Red Hat UBI**:
  - `registry.access.redhat.com/ubi8/ubi`
  - `registry.access.redhat.com/ubi8/dotnet-60`
  - `registry.access.redhat.com/ubi8/nodejs-16`
  - `registry.access.redhat.com/ubi9/python-39`

#### Code Examples

- **.NET examples**: Use C# with ASP.NET Core, Entity Framework, etc.
- **React Native examples**: Use TypeScript when possible
- **Testing frameworks**: xUnit for .NET, Jest for React Native
- **Include error handling and logging**

#### Commands and Scripts

```bash
# Use Podman commands
podman build -t myapp .
podman run -d --name myapp-container myapp

# Use podman compose 
podman compose up -d
podman compose down
```

### Writing Style

#### Tone and Language

- **Clear and conversational** - avoid overly technical jargon
- **Practical and actionable** - focus on what developers can do immediately
- **Progressive complexity** - start simple, add complexity gradually
- **Include real-world scenarios** - relate to actual development challenges

#### Code Quality

- **Working examples only** - test all code snippets
- **Comment extensively** - explain what each section does
- **Include error scenarios** - show how to handle failures
- **Security-first** - demonstrate secure coding practices

## 🛠️ Technical Examples Templates

### Podman Container Example Template

```Containerfile
# Use Red Hat UBI as base image
FROM registry.access.redhat.com/ubi8/dotnet-60

# Set working directory
WORKDIR /app

# Copy and restore dependencies
COPY *.csproj ./
RUN dotnet restore

# Copy source code
COPY . ./

# Build application
RUN dotnet publish -c Release -o out

# Set entry point
ENTRYPOINT ["dotnet", "out/MyApp.dll"]
```

### podman compose  Example Template

```yaml
version: '3'
services:
  web:
    build: 
      context: .
      Containerfile: Containerfile
    ports:
      - "5000:5000"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
    depends_on:
      - database
      
  database:
    image: registry.access.redhat.com/rhel8/postgresql-13
    environment:
      - POSTGRESQL_DATABASE=myapp
      - POSTGRESQL_USER=appuser
      - POSTGRESQL_PASSWORD=secure_password
    volumes:
      - postgres_data:/var/lib/pgsql/data
      
volumes:
  postgres_data:
```

### .NET API Example Template

```csharp
// Example for API development sections
[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly ILogger<ProductsController> _logger;
    private readonly IProductService _productService;
    
    public ProductsController(
        ILogger<ProductsController> logger, 
        IProductService productService)
    {
        _logger = logger;
        _productService = productService;
    }
    
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Product>>> GetProducts()
    {
        try
        {
            var products = await _productService.GetAllProductsAsync();
            return Ok(products);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error retrieving products");
            return StatusCode(500, "Internal server error");
        }
    }
}
```

### React Native Component Example Template

```typescript
// Example for mobile development sections
import React, { useEffect, useState } from 'react';
import { View, Text, FlatList, ActivityIndicator } from 'react-native';

interface Product {
  id: string;
  name: string;
  price: number;
}

const ProductList: React.FC = () => {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchProducts();
  }, []);

  const fetchProducts = async () => {
    try {
      const response = await fetch('https://api.example.com/products');
      if (!response.ok) {
        throw new Error('Failed to fetch products');
      }
      const data = await response.json();
      setProducts(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <ActivityIndicator size="large" />;
  if (error) return <Text>Error: {error}</Text>;

  return (
    <FlatList
      data={products}
      keyExtractor={(item) => item.id}
      renderItem={({ item }) => (
        <View>
          <Text>{item.name}</Text>
          <Text>${item.price}</Text>
        </View>
      )}
    />
  );
};

export default ProductList;
```

## 📋 Content Requirements by Section

### For Containerization Topics

- Show Podman installation and setup
- Explain differences between Podman and Docker
- Demonstrate rootless containers
- Include multi-stage builds with UBI images
- Show networking and volume management

### For Development Practices

- Focus on developer experience and productivity
- Include IDE setup and debugging
- Show integration with CI/CD pipelines
- Demonstrate testing strategies
- Include performance considerations

### For Cloud Native Topics

- Explain 12-factor app principles with examples
- Show configuration management
- Demonstrate service discovery and communication
- Include observability and monitoring
- Show deployment strategies

### For Testing Topics

- Unit testing with xUnit (.NET) and Jest (React Native)
- Integration testing with Testcontainers
- BDD with SpecFlow (.NET) and Cucumber (React Native)
- Performance testing in containerized environments
- Security testing practices

## 🔍 Quality Checklist

Before submitting documentation, ensure:

- [ ] All code examples use Podman (not Docker)
- [ ] All container images are Red Hat UBI-based
- [ ] Examples are tested and working
- [ ] Content is appropriate for junior/mid-senior developers
- [ ] Includes both .NET and React Native examples where applicable
- [ ] Follows the standard document structure
- [ ] Contains practical, hands-on exercises
- [ ] Includes common pitfalls and solutions
- [ ] Has clear, actionable best practices
- [ ] Links to relevant additional resources

## 🚀 Getting Started

1. **Choose a topic** from the file structure above
2. **Review existing content** (if any) in the corresponding `.md` file
3. **Follow the writing guidelines** and use the provided templates
4. **Test all code examples** with Podman and UBI images
5. **Submit for review** ensuring the quality checklist is complete

## 📞 Support and Questions

For questions about these documentation guidelines or specific technical topics, refer to:

- [Red Hat UBI Documentation](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/building_running_and_managing_containers/using_red_hat_universal_base_images_standard_minimal_and_runtimes)
- [Podman Documentation](https://docs.podman.io/)
- [ASP.NET Core Documentation](https://docs.microsoft.com/en-us/aspnet/core/)
- [React Native Documentation](https://reactnative.dev/docs/getting-started)

Remember: The goal is to create practical, actionable documentation that helps developers succeed in modern software development practices using Red Hat technologies and open-source tools.
