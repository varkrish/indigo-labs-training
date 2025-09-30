# Mocking Dependent Systems and APIs

## Overview

Modern software applications integrate with multiple external systems including payment processors, authentication services, data providers, and third-party APIs. While these integrations enable rich functionality, they introduce significant challenges for testing, development, and continuous integration processes.

Mocking provides a systematic approach to simulate external system behavior, enabling comprehensive testing without the complexity, cost, and reliability issues associated with live integrations. This guide focuses on practical mocking strategies for .NET and React Native applications using industry-standard tools and containerized approaches.

## External Dependency Challenges

### Testing Complexity

External system dependencies introduce several obstacles to effective testing:

- **Environment Inconsistency**: External services may behave differently across development, staging, and production environments
- **Network Reliability**: Internet connectivity issues, service outages, and network latency affect test reliability
- **Rate Limiting**: API quotas and throttling mechanisms limit the volume of test requests
- **Financial Costs**: Pay-per-use APIs accumulate costs during extensive testing cycles
- **Data Management**: Live systems may create persistent data that affects subsequent test runs

### Development Workflow Impact

External dependencies affect development productivity through:

- **Slow Feedback Cycles**: Network requests significantly increase test execution time
- **Offline Development**: Inability to develop or test without internet connectivity
- **Scenario Coverage**: Difficulty triggering specific edge cases, error conditions, or failure modes
- **Team Coordination**: Shared external resources may create conflicts between development teams

## Mocking Strategy Benefits

### Test Reliability

Mocking implementations provide predictable behavior that supports reliable testing:

- **Deterministic Responses**: Controlled output enables consistent test results
- **Error Simulation**: Systematic testing of failure scenarios and edge cases
- **Performance Consistency**: Elimination of network variability improves test reliability
- **Isolation**: Individual component testing without external system dependencies

### Development Efficiency

Mock implementations enhance development workflows through:

- **Rapid Iteration**: Immediate feedback without network delays
- **Offline Capability**: Development and testing without external system availability
- **Cost Reduction**: Elimination of API usage charges during development
- **Parallel Development**: Teams can work independently of external system availability

## Testing Implementation Strategies

### Unit Testing with Dependency Injection

Mock individual dependencies at the component level using dependency injection patterns:

**Advantages:**

- Rapid test execution with minimal overhead
- Complete control over dependency behavior
- Isolated testing of business logic
- Simple setup and configuration

**Implementation Focus:**

- Interface-based dependency abstraction
- Constructor injection for testability
- Mock framework integration with testing containers

### Integration Testing with Service Stubs

Replace complete external systems with lightweight stub implementations:

**Advantages:**

- End-to-end workflow validation
- Network protocol testing
- Service contract verification
- Multi-component integration scenarios

**Implementation Focus:**

- HTTP-based stub services
- Message queue simulation
- Database connection mocking
- Authentication service stubs

### Contract Testing Implementation

Establish and verify API contracts between service consumers and providers:

**Advantages:**

- Consumer-driven contract validation
- Breaking change detection
- Team coordination through shared contracts
- Provider behavior verification

**Implementation Focus:**

- Schema definition and validation
- Contract generation and publishing
- Automated contract testing
- Version compatibility verification

## .NET Mocking Implementation

### Moq Framework with Dependency Injection

Implement unit testing with Moq and Microsoft.Extensions.DependencyInjection:

```csharp
// Service interface definition
public interface IPaymentService
{
    Task<PaymentResult> ProcessPaymentAsync(PaymentRequest request);
}

// Service implementation under test
public class OrderService
{
    private readonly IPaymentService _paymentService;
    
    public OrderService(IPaymentService paymentService)
    {
        _paymentService = paymentService;
    }
    
    public async Task<OrderResult> CreateOrderAsync(CreateOrderRequest request)
    {
        var paymentResult = await _paymentService.ProcessPaymentAsync(
            new PaymentRequest 
            { 
                Amount = request.Total, 
                CardToken = request.PaymentToken 
            });
            
        if (!paymentResult.IsSuccessful)
        {
            return OrderResult.Failed("Payment processing failed");
        }
        
        return OrderResult.Success(new Order { Id = Guid.NewGuid() });
    }
}

// xUnit test implementation
[Fact]
public async Task CreateOrderAsync_PaymentSuccessful_ReturnsSuccessResult()
{
    // Arrange
    var mockPaymentService = new Mock<IPaymentService>();
    mockPaymentService
        .Setup(x => x.ProcessPaymentAsync(It.IsAny<PaymentRequest>()))
        .ReturnsAsync(new PaymentResult { IsSuccessful = true, TransactionId = "12345" });
    
    var orderService = new OrderService(mockPaymentService.Object);
    var request = new CreateOrderRequest { Total = 100.00m, PaymentToken = "token123" };
    
    // Act
    var result = await orderService.CreateOrderAsync(request);
    
    // Assert
    Assert.True(result.IsSuccess);
    mockPaymentService.Verify(
        x => x.ProcessPaymentAsync(It.Is<PaymentRequest>(p => p.Amount == 100.00m)), 
        Times.Once);
}

[Fact]
public async Task CreateOrderAsync_PaymentFailed_ReturnsFailureResult()
{
    // Arrange
    var mockPaymentService = new Mock<IPaymentService>();
    mockPaymentService
        .Setup(x => x.ProcessPaymentAsync(It.IsAny<PaymentRequest>()))
        .ReturnsAsync(new PaymentResult { IsSuccessful = false, ErrorMessage = "Insufficient funds" });
    
    var orderService = new OrderService(mockPaymentService.Object);
    var request = new CreateOrderRequest { Total = 100.00m, PaymentToken = "token123" };
    
    // Act
    var result = await orderService.CreateOrderAsync(request);
    
    // Assert
    Assert.False(result.IsSuccess);
    Assert.Contains("Payment processing failed", result.ErrorMessage);
}
```

### WireMock.NET for Integration Testing

Implement HTTP service mocking for integration tests:

```csharp
// Test setup with WireMock server
public class PaymentIntegrationTests : IDisposable
{
    private readonly WireMockServer _wireMockServer;
    private readonly HttpClient _httpClient;
    private readonly PaymentService _paymentService;
    
    public PaymentIntegrationTests()
    {
        _wireMockServer = WireMockServer.Start();
        _httpClient = new HttpClient { BaseAddress = new Uri(_wireMockServer.Urls[0]) };
        _paymentService = new PaymentService(_httpClient);
    }
    
    [Fact]
    public async Task ProcessPaymentAsync_SuccessfulResponse_ReturnsSuccess()
    {
        // Arrange
        _wireMockServer
            .Given(Request.Create()
                .WithPath("/api/payments")
                .WithMethod("POST")
                .WithBodyAsJson(new { amount = 100.00, cardToken = "token123" }))
            .RespondWith(Response.Create()
                .WithStatusCode(200)
                .WithBodyAsJson(new { transactionId = "12345", status = "approved" }));
        
        var request = new PaymentRequest { Amount = 100.00m, CardToken = "token123" };
        
        // Act
        var result = await _paymentService.ProcessPaymentAsync(request);
        
        // Assert
        Assert.True(result.IsSuccessful);
        Assert.Equal("12345", result.TransactionId);
    }
    
    [Fact]
    public async Task ProcessPaymentAsync_ServiceError_ReturnsFailure()
    {
        // Arrange
        _wireMockServer
            .Given(Request.Create()
                .WithPath("/api/payments")
                .WithMethod("POST"))
            .RespondWith(Response.Create()
                .WithStatusCode(500)
                .WithBodyAsJson(new { error = "Internal server error" }));
        
        var request = new PaymentRequest { Amount = 100.00m, CardToken = "token123" };
        
        // Act
        var result = await _paymentService.ProcessPaymentAsync(request);
        
        // Assert
        Assert.False(result.IsSuccessful);
        Assert.Contains("Internal server error", result.ErrorMessage);
    }
    
    public void Dispose()
    {
        _wireMockServer?.Stop();
        _httpClient?.Dispose();
    }
}
```

## React Native Mocking Implementation

### Jest with Mock Service Worker

Implement comprehensive API mocking for React Native applications:

```typescript
// API service interface
export interface UserService {
  fetchUser(id: string): Promise<User>;
  updateUser(id: string, updates: Partial<User>): Promise<User>;
}

// Component under test
interface UserProfileProps {
  userId: string;
  userService: UserService;
}

export const UserProfile: React.FC<UserProfileProps> = ({ userId, userService }) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  
  useEffect(() => {
    const loadUser = async () => {
      try {
        setLoading(true);
        const userData = await userService.fetchUser(userId);
        setUser(userData);
      } catch (err) {
        setError('Failed to load user data');
      } finally {
        setLoading(false);
      }
    };
    
    loadUser();
  }, [userId, userService]);
  
  if (loading) return <ActivityIndicator testID="loading-indicator" />;
  if (error) return <Text testID="error-message">{error}</Text>;
  if (!user) return <Text testID="no-user">User not found</Text>;
  
  return (
    <View testID="user-profile">
      <Text testID="user-name">{user.name}</Text>
      <Text testID="user-email">{user.email}</Text>
    </View>
  );
};

// Jest test implementation
import { render, waitFor } from '@testing-library/react-native';
import { UserProfile } from '../UserProfile';
import { UserService } from '../services/UserService';

describe('UserProfile Component', () => {
  const mockUserService: jest.Mocked<UserService> = {
    fetchUser: jest.fn(),
    updateUser: jest.fn(),
  };
  
  beforeEach(() => {
    jest.clearAllMocks();
  });
  
  it('displays user information when loaded successfully', async () => {
    // Arrange
    const mockUser = {
      id: '123',
      name: 'John Doe',
      email: 'john.doe@example.com'
    };
    
    mockUserService.fetchUser.mockResolvedValue(mockUser);
    
    // Act
    const { getByTestId } = render(
      <UserProfile userId="123" userService={mockUserService} />
    );
    
    // Assert
    await waitFor(() => {
      expect(getByTestId('user-name')).toHaveTextContent('John Doe');
      expect(getByTestId('user-email')).toHaveTextContent('john.doe@example.com');
    });
    
    expect(mockUserService.fetchUser).toHaveBeenCalledWith('123');
  });
  
  it('displays error message when service fails', async () => {
    // Arrange
    mockUserService.fetchUser.mockRejectedValue(new Error('Network error'));
    
    // Act
    const { getByTestId } = render(
      <UserProfile userId="123" userService={mockUserService} />
    );
    
    // Assert
    await waitFor(() => {
      expect(getByTestId('error-message')).toHaveTextContent('Failed to load user data');
    });
  });
});
```

### MSW Integration for Network Mocking

Implement Mock Service Worker for comprehensive network request mocking:

```typescript
// MSW handlers setup
import { rest } from 'msw';
import { setupServer } from 'msw/node';

export const handlers = [
  rest.get('/api/users/:id', (req, res, ctx) => {
    const { id } = req.params;
    
    return res(
      ctx.status(200),
      ctx.json({
        id,
        name: 'John Doe',
        email: 'john.doe@example.com',
        avatar: 'https://example.com/avatar.jpg'
      })
    );
  }),
  
  rest.put('/api/users/:id', async (req, res, ctx) => {
    const { id } = req.params;
    const updates = await req.json();
    
    return res(
      ctx.status(200),
      ctx.json({
        id,
        ...updates,
        updatedAt: new Date().toISOString()
      })
    );
  }),
  
  rest.get('/api/users/:id/orders', (req, res, ctx) => {
    const { id } = req.params;
    
    return res(
      ctx.status(200),
      ctx.json([
        {
          id: 'order1',
          userId: id,
          amount: 99.99,
          status: 'completed'
        }
      ])
    );
  })
];

export const server = setupServer(...handlers);

// Test setup configuration
import { server } from './mocks/server';

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

// Integration test with MSW
describe('User Service Integration', () => {
  it('fetches and displays user with orders', async () => {
    // Arrange
    const { getByTestId } = render(<UserProfileScreen userId="123" />);
    
    // Act & Assert
    await waitFor(() => {
      expect(getByTestId('user-name')).toHaveTextContent('John Doe');
      expect(getByTestId('order-count')).toHaveTextContent('1 order');
    });
  });
  
  it('handles server error gracefully', async () => {
    // Arrange
    server.use(
      rest.get('/api/users/123', (req, res, ctx) => {
        return res(ctx.status(500), ctx.json({ error: 'Internal server error' }));
      })
    );
    
    const { getByTestId } = render(<UserProfileScreen userId="123" />);
    
    // Act & Assert
    await waitFor(() => {
      expect(getByTestId('error-message')).toHaveTextContent('Failed to load user data');
    });
  });
});
```

### React Native Component Testing

Implement comprehensive component testing with mock dependencies:

```typescript
// Service hook with error handling
export const useUserData = (userId: string) => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  
  const fetchUser = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const userData = await userService.fetchUser(userId);
      setUser(userData);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error');
    } finally {
      setLoading(false);
    }
  }, [userId]);
  
  useEffect(() => {
    fetchUser();
  }, [fetchUser]);
  
  return { user, loading, error, refetch: fetchUser };
};

// Component test with custom hook mocking
jest.mock('../hooks/useUserData');

describe('UserProfileScreen', () => {
  const mockUseUserData = useUserData as jest.MockedFunction<typeof useUserData>;
  
  beforeEach(() => {
    jest.clearAllMocks();
  });
  
  it('renders user profile when data loads successfully', () => {
    // Arrange
    mockUseUserData.mockReturnValue({
      user: {
        id: '123',
        name: 'Jane Smith',
        email: 'jane.smith@example.com',
        avatar: 'https://example.com/avatar.jpg'
      },
      loading: false,
      error: null,
      refetch: jest.fn()
    });
    
    // Act
    const { getByTestId } = render(<UserProfileScreen userId="123" />);
    
    // Assert
    expect(getByTestId('user-name')).toHaveTextContent('Jane Smith');
    expect(getByTestId('user-email')).toHaveTextContent('jane.smith@example.com');
    expect(getByTestId('user-avatar')).toBeTruthy();
  });
  
  it('shows loading state while fetching data', () => {
    // Arrange
    mockUseUserData.mockReturnValue({
      user: null,
      loading: true,
      error: null,
      refetch: jest.fn()
    });
    
    // Act
    const { getByTestId } = render(<UserProfileScreen userId="123" />);
    
    // Assert
    expect(getByTestId('loading-indicator')).toBeTruthy();
  });
  
  it('displays error message and retry button when fetch fails', () => {
    // Arrange
    const mockRefetch = jest.fn();
    mockUseUserData.mockReturnValue({
      user: null,
      loading: false,
      error: 'Network connection failed',
      refetch: mockRefetch
    });
    
    // Act
    const { getByTestId } = render(<UserProfileScreen userId="123" />);
    
    // Assert
    expect(getByTestId('error-message')).toHaveTextContent('Network connection failed');
    
    // Test retry functionality
    fireEvent.press(getByTestId('retry-button'));
    expect(mockRefetch).toHaveBeenCalledTimes(1);
  });
});
```

## Containerized Mock Services with Podman

### Docker Mock Service Configuration

Create containerized mock services using Red Hat UBI images:

```dockerfile
# Mock API service Dockerfile
FROM registry.access.redhat.com/ubi9/nodejs-18:latest

USER root

# Install WireMock standalone
RUN dnf update -y && \
    dnf install -y java-11-openjdk-headless wget && \
    dnf clean all

WORKDIR /app

# Download WireMock standalone JAR
RUN wget https://repo1.maven.org/maven2/com/github/tomakehurst/wiremock-jre8-standalone/2.35.0/wiremock-jre8-standalone-2.35.0.jar \
    -O wiremock-standalone.jar

# Copy mock configuration
COPY mappings/ /app/mappings/
COPY __files/ /app/__files/

USER 1001

EXPOSE 8080

CMD ["java", "-jar", "wiremock-standalone.jar", "--port", "8080", "--verbose"]
```

### Mock Service Configuration Files

Configure WireMock mappings for containerized mock services:

```json
// mappings/user-api.json
{
  "mappings": [
    {
      "request": {
        "method": "GET",
        "urlPathPattern": "/api/users/([0-9]+)"
      },
      "response": {
        "status": 200,
        "headers": {
          "Content-Type": "application/json"
        },
        "bodyFileName": "user-response.json",
        "transformers": ["response-template"]
      }
    },
    {
      "request": {
        "method": "POST",
        "urlPath": "/api/users",
        "bodyPatterns": [
          {
            "matchesJsonPath": "$.name"
          }
        ]
      },
      "response": {
        "status": 201,
        "headers": {
          "Content-Type": "application/json"
        },
        "body": "{\"id\": \"{{randomValue length=10 type='ALPHANUMERIC'}}\", \"name\": \"{{jsonPath request.body '$.name'}}\", \"createdAt\": \"{{now}}\"}",
        "transformers": ["response-template"]
      }
    }
  ]
}
```

```json
// __files/user-response.json
{
  "id": "123",
  "name": "Mock User",
  "email": "mock.user@example.com",
  "avatar": "https://mock-service/avatars/default.jpg",
  "preferences": {
    "theme": "dark",
    "notifications": true
  },
  "metadata": {
    "lastLogin": "{{now format='yyyy-MM-dd HH:mm:ss'}}",
    "loginCount": "{{randomValue length=2 type='NUMERIC'}}"
  }
}
```

### Podman Compose Configuration

Configure containerized mock services with Podman Compose:

```yaml
# compose-mocks.yml
version: '3.8'

services:
  mock-user-api:
    build:
      context: ./mocks/user-api
      dockerfile: Dockerfile
    ports:
      - "8080:8080"
    environment:
      - WIREMOCK_OPTIONS=--global-response-templating
    volumes:
      - ./mocks/user-api/mappings:/app/mappings:ro
      - ./mocks/user-api/__files:/app/__files:ro
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/__admin/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    networks:
      - mock-network

  mock-payment-api:
    build:
      context: ./mocks/payment-api
      dockerfile: Dockerfile
    ports:
      - "8081:8080"
    environment:
      - WIREMOCK_OPTIONS=--global-response-templating --async-response-enabled
    volumes:
      - ./mocks/payment-api/mappings:/app/mappings:ro
      - ./mocks/payment-api/__files:/app/__files:ro
    depends_on:
      - mock-user-api
    networks:
      - mock-network

networks:
  mock-network:
    driver: bridge
```

### Integration Test Configuration

Configure integration tests with containerized mock services:

```csharp
// Integration test with containerized mocks
public class ContainerizedMockTests : IAsyncLifetime
{
    private readonly IContainer _mockContainer;
    private readonly HttpClient _httpClient;
    
    public ContainerizedMockTests()
    {
        _mockContainer = new ContainerBuilder()
            .WithImage("mock-user-api:latest")
            .WithPortBinding(8080, true)
            .WithWaitStrategy(Wait.ForUnixContainer()
                .UntilHttpRequestIsSucceeded(r => r.ForPort(8080).ForPath("/__admin/health")))
            .Build();
            
        _httpClient = new HttpClient();
    }
    
    public async Task InitializeAsync()
    {
        await _mockContainer.StartAsync();
        var mockPort = _mockContainer.GetMappedPublicPort(8080);
        _httpClient.BaseAddress = new Uri($"http://localhost:{mockPort}");
    }
    
    [Fact]
    public async Task GetUser_ContainerizedMock_ReturnsExpectedData()
    {
        // Act
        var response = await _httpClient.GetAsync("/api/users/123");
        var content = await response.Content.ReadAsStringAsync();
        var user = JsonSerializer.Deserialize<User>(content);
        
        // Assert
        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
        Assert.Equal("123", user.Id);
        Assert.Equal("Mock User", user.Name);
    }
    
    public async Task DisposeAsync()
    {
        _httpClient?.Dispose();
        await _mockContainer.DisposeAsync();
    }
}
```

### Mock Service Management Scripts

Integrate mock services into development workflows:

```bash
#!/bin/bash
# scripts/start-mocks.sh

echo "Starting containerized mock services..."

# Build mock service images
podman build -t mock-user-api:latest ./mocks/user-api/
podman build -t mock-payment-api:latest ./mocks/payment-api/

# Start mock services with Podman Compose
podman-compose -f compose-mocks.yml up -d

# Wait for services to be ready
echo "Waiting for mock services to be ready..."
until curl -sf http://localhost:8080/__admin/health > /dev/null; do
    sleep 2
done

until curl -sf http://localhost:8081/__admin/health > /dev/null; do
    sleep 2
done

echo "Mock services are ready!"
echo "User API: http://localhost:8080"
echo "Payment API: http://localhost:8081"
echo "WireMock Admin: http://localhost:8080/__admin/"
```

```bash
#!/bin/bash
# scripts/stop-mocks.sh

echo "Stopping containerized mock services..."
podman-compose -f compose-mocks.yml down

echo "Cleaning up mock service images..."
podman rmi mock-user-api:latest mock-payment-api:latest 2>/dev/null || true

echo "Mock services stopped and cleaned up."
```

## Best Practices and Recommendations

### Mock Service Design Principles

**Service Isolation**: Design mock services to operate independently without external dependencies, ensuring reliable test execution in any environment.

**Data Consistency**: Maintain consistent mock data across test scenarios while supporting dynamic response generation for varied test conditions.

**Performance Optimization**: Configure mock services for rapid response times to maintain fast test execution cycles and immediate feedback.

**Security Compliance**: Implement mock services using security-hardened base images and follow container security best practices.

### Development Process Integration

**Continuous Integration**: Integrate mock services into CI/CD pipelines using containerized deployment strategies that support parallel test execution.

**Local Development**: Provide simple scripts and documentation for developers to start and stop mock services during local development cycles.

**environment Parity**: Ensure mock service behavior closely matches production system behavior to prevent integration issues.

**Version Management**: Maintain mock service versions alongside application versions to support parallel development and testing workflows.

### Testing Strategy Implementation

**Test Pyramid Alignment**: Use unit-level mocks for rapid feedback and integration-level mocks for comprehensive workflow validation.

**Scenario Coverage**: Design mock services to support comprehensive test scenario coverage including success paths, error conditions, and edge cases.

**Contract Validation**: Implement contract testing to ensure mock services accurately represent real system behavior and API specifications.

**Monitoring and Observability**: Include logging and monitoring capabilities in mock services to support test debugging and system understanding.
