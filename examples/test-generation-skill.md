# Example: Test Generation Skill

This example demonstrates a skill for automatically generating tests for your code.

## Skill Definition

```yaml
skill:
  id: "test-generator"
  version: "1.0.0"
  name: "Test Generator"
  description: "Generates comprehensive unit tests for functions and classes"
  category: "testing"
  
  metadata:
    author: "Awesome-CoPilot"
    tags: ["testing", "tdd", "quality"]
    languages: ["javascript", "typescript", "python", "java"]
  
  inputs:
    - name: "source_code"
      type: "string"
      required: true
      description: "The source code to generate tests for"
    
    - name: "language"
      type: "enum"
      values: ["javascript", "typescript", "python", "java"]
      required: true
      description: "Programming language of the source code"
    
    - name: "framework"
      type: "string"
      required: false
      description: "Testing framework to use (auto-detected if not specified)"
    
    - name: "coverage_target"
      type: "number"
      required: false
      default: 80
      description: "Target code coverage percentage"
  
  outputs:
    - name: "test_code"
      type: "string"
      description: "Generated test code"
    
    - name: "coverage_estimate"
      type: "number"
      description: "Estimated coverage percentage"
  
  steps:
    - action: "parse_code"
      description: "Parse source code to identify testable units"
      output: "parsed_units"
    
    - action: "identify_test_cases"
      description: "Identify test cases (happy path, edge cases, errors)"
      input: "parsed_units"
      output: "test_cases"
    
    - action: "generate_test_code"
      description: "Generate test implementation"
      input: "test_cases"
      output: "test_code"
    
    - action: "estimate_coverage"
      description: "Estimate code coverage"
      input: ["parsed_units", "test_cases"]
      output: "coverage_estimate"
```

## Usage Examples

### JavaScript/TypeScript Example

**Source Code**:
```typescript
// userService.ts
export class UserService {
  constructor(private db: Database) {}
  
  async createUser(email: string, name: string): Promise<User> {
    if (!email || !name) {
      throw new Error('Email and name are required');
    }
    
    const existingUser = await this.db.findUserByEmail(email);
    if (existingUser) {
      throw new Error('User already exists');
    }
    
    const user = await this.db.createUser({ email, name });
    return user;
  }
  
  async getUserById(id: string): Promise<User | null> {
    return this.db.findUserById(id);
  }
}
```

**Generated Tests**:
```typescript
// userService.test.ts
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { UserService } from './userService';
import { Database } from './database';

describe('UserService', () => {
  let userService: UserService;
  let mockDb: ReturnType<typeof vi.mocked<Database>>;
  
  beforeEach(() => {
    mockDb = {
      findUserByEmail: vi.fn(),
      createUser: vi.fn(),
      findUserById: vi.fn(),
    } as any;
    
    userService = new UserService(mockDb);
  });
  
  describe('createUser', () => {
    it('should create a new user with valid data', async () => {
      // Arrange
      const email = 'test@example.com';
      const name = 'Test User';
      const expectedUser = { id: '1', email, name };
      
      mockDb.findUserByEmail.mockResolvedValue(null);
      mockDb.createUser.mockResolvedValue(expectedUser);
      
      // Act
      const result = await userService.createUser(email, name);
      
      // Assert
      expect(result).toEqual(expectedUser);
      expect(mockDb.findUserByEmail).toHaveBeenCalledWith(email);
      expect(mockDb.createUser).toHaveBeenCalledWith({ email, name });
    });
    
    it('should throw error when email is missing', async () => {
      // Act & Assert
      await expect(
        userService.createUser('', 'Test User')
      ).rejects.toThrow('Email and name are required');
      
      expect(mockDb.findUserByEmail).not.toHaveBeenCalled();
      expect(mockDb.createUser).not.toHaveBeenCalled();
    });
    
    it('should throw error when name is missing', async () => {
      // Act & Assert
      await expect(
        userService.createUser('test@example.com', '')
      ).rejects.toThrow('Email and name are required');
    });
    
    it('should throw error when user already exists', async () => {
      // Arrange
      const email = 'existing@example.com';
      const existingUser = { id: '1', email, name: 'Existing' };
      mockDb.findUserByEmail.mockResolvedValue(existingUser);
      
      // Act & Assert
      await expect(
        userService.createUser(email, 'New User')
      ).rejects.toThrow('User already exists');
      
      expect(mockDb.createUser).not.toHaveBeenCalled();
    });
  });
  
  describe('getUserById', () => {
    it('should return user when found', async () => {
      // Arrange
      const userId = '123';
      const expectedUser = { id: userId, email: 'test@example.com', name: 'Test' };
      mockDb.findUserById.mockResolvedValue(expectedUser);
      
      // Act
      const result = await userService.getUserById(userId);
      
      // Assert
      expect(result).toEqual(expectedUser);
      expect(mockDb.findUserById).toHaveBeenCalledWith(userId);
    });
    
    it('should return null when user not found', async () => {
      // Arrange
      mockDb.findUserById.mockResolvedValue(null);
      
      // Act
      const result = await userService.getUserById('nonexistent');
      
      // Assert
      expect(result).toBeNull();
    });
  });
});

// Estimated Coverage: 95%
```

### Python Example

**Source Code**:
```python
# calculator.py
class Calculator:
    def add(self, a: float, b: float) -> float:
        """Add two numbers."""
        return a + b
    
    def divide(self, a: float, b: float) -> float:
        """Divide a by b."""
        if b == 0:
            raise ValueError("Cannot divide by zero")
        return a / b
    
    def power(self, base: float, exponent: int) -> float:
        """Raise base to the power of exponent."""
        if exponent < 0:
            raise ValueError("Negative exponents not supported")
        return base ** exponent
```

**Generated Tests**:
```python
# test_calculator.py
import pytest
from calculator import Calculator

class TestCalculator:
    @pytest.fixture
    def calculator(self):
        """Create a Calculator instance for testing."""
        return Calculator()
    
    class TestAdd:
        def test_add_positive_numbers(self, calculator):
            """Test adding two positive numbers."""
            result = calculator.add(5, 3)
            assert result == 8
        
        def test_add_negative_numbers(self, calculator):
            """Test adding two negative numbers."""
            result = calculator.add(-5, -3)
            assert result == -8
        
        def test_add_mixed_numbers(self, calculator):
            """Test adding positive and negative numbers."""
            result = calculator.add(5, -3)
            assert result == 2
        
        def test_add_with_zero(self, calculator):
            """Test adding with zero."""
            result = calculator.add(5, 0)
            assert result == 5
        
        def test_add_floats(self, calculator):
            """Test adding floating point numbers."""
            result = calculator.add(1.5, 2.5)
            assert result == pytest.approx(4.0)
    
    class TestDivide:
        def test_divide_positive_numbers(self, calculator):
            """Test dividing two positive numbers."""
            result = calculator.divide(10, 2)
            assert result == 5.0
        
        def test_divide_with_remainder(self, calculator):
            """Test division with remainder."""
            result = calculator.divide(10, 3)
            assert result == pytest.approx(3.333, rel=1e-3)
        
        def test_divide_by_zero_raises_error(self, calculator):
            """Test that dividing by zero raises ValueError."""
            with pytest.raises(ValueError, match="Cannot divide by zero"):
                calculator.divide(10, 0)
        
        def test_divide_zero_by_number(self, calculator):
            """Test dividing zero by a number."""
            result = calculator.divide(0, 5)
            assert result == 0.0
        
        def test_divide_negative_numbers(self, calculator):
            """Test dividing negative numbers."""
            result = calculator.divide(-10, -2)
            assert result == 5.0
    
    class TestPower:
        def test_power_positive_exponent(self, calculator):
            """Test raising to positive exponent."""
            result = calculator.power(2, 3)
            assert result == 8
        
        def test_power_zero_exponent(self, calculator):
            """Test raising to power of zero."""
            result = calculator.power(5, 0)
            assert result == 1
        
        def test_power_one_exponent(self, calculator):
            """Test raising to power of one."""
            result = calculator.power(5, 1)
            assert result == 5
        
        def test_power_negative_exponent_raises_error(self, calculator):
            """Test that negative exponent raises ValueError."""
            with pytest.raises(ValueError, match="Negative exponents not supported"):
                calculator.power(2, -1)
        
        def test_power_with_float_base(self, calculator):
            """Test power with floating point base."""
            result = calculator.power(1.5, 2)
            assert result == pytest.approx(2.25)
        
        def test_power_large_exponent(self, calculator):
            """Test power with large exponent."""
            result = calculator.power(2, 10)
            assert result == 1024

# Estimated Coverage: 100%
```

## How to Use the Skill

### In VS Code with Copilot

1. **Using Chat**:
   ```
   @workspace Use the test-generator skill to create tests for userService.ts
   ```

2. **Using Comments**:
   ```typescript
   // @copilot-skill test-generator
   // Generate tests for this class
   class MyService { ... }
   ```

3. **Using Command Palette**:
   - Open Command Palette (Cmd/Ctrl + Shift + P)
   - Type "Copilot: Generate Tests"
   - Select the code to test

### Command Line

```bash
# Note: These are example commands showing how a skill system might work
# Actual implementation may vary based on your Copilot setup

# Generate tests for a file
copilot skill test-generator --input src/userService.ts --output tests/userService.test.ts

# Generate tests with specific framework
copilot skill test-generator --input src/calculator.py --framework pytest --output tests/test_calculator.py

# Generate tests with coverage target
copilot skill test-generator --input src/app.js --coverage-target 90
```

## Configuration

### JavaScript/TypeScript Projects

Add to `package.json`:
```json
{
  "copilot": {
    "skills": {
      "test-generator": {
        "framework": "vitest",
        "coverage_target": 80,
        "test_directory": "tests",
        "mocking_library": "@vitest/spy"
      }
    }
  }
}
```

### Python Projects

Add to `pyproject.toml`:
```toml
[tool.copilot.skills.test-generator]
framework = "pytest"
coverage_target = 90
test_directory = "tests"
fixtures_file = "tests/conftest.py"
```

## Advanced Features

### Custom Test Templates

```yaml
templates:
  - name: "api_endpoint_test"
    pattern: "Express route handler"
    template: |
      describe('{{method}} {{path}}', () => {
        it('should return {{status}} on success', async () => {
          const response = await request(app)
            .{{method}}('{{path}}')
            .send({{request_body}});
          
          expect(response.status).toBe({{status}});
          expect(response.body).toEqual({{expected_response}});
        });
        
        it('should return 400 on invalid input', async () => {
          // Test validation
        });
      });
```

### Integration with Coverage Tools

```yaml
post_generation:
  - action: "run_tests"
    command: "npm test"
  
  - action: "measure_coverage"
    command: "npm run coverage"
    output: "coverage_report"
  
  - action: "compare_coverage"
    target: "coverage_target"
    actual: "coverage_report.percentage"
  
  - action: "suggest_improvements"
    if: "actual < target"
    suggestions:
      - "Add tests for uncovered branches"
      - "Test edge cases"
      - "Test error conditions"
```

## Tips for Better Test Generation

1. **Provide Context**: Include type definitions and interfaces
2. **Document Edge Cases**: Add comments about expected behavior
3. **Use Descriptive Names**: Clear function names help generate better tests
4. **Include Examples**: Existing tests help establish patterns
5. **Review Generated Tests**: Always review and refine generated tests

## Resources

- [Testing Best Practices](https://github.com/goldbergyoni/javascript-testing-best-practices)
- [Vitest Documentation](https://vitest.dev/)
- [Jest Documentation](https://jestjs.io/)
- [Pytest Documentation](https://docs.pytest.org/)
