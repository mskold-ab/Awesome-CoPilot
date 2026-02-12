# GitHub Copilot Skills Guide

## What are Copilot Skills?

Skills are reusable capabilities that enhance GitHub Copilot's ability to perform specific tasks. They can be thought of as specialized functions or workflows that Copilot can leverage to help developers.

## Skill Categories

### 1. Code Generation Skills

#### Boilerplate Generation
- Project scaffolding
- Component templates
- Configuration files
- Standard patterns

#### API Client Generation
- REST API clients
- GraphQL clients
- SDK generation
- Type definitions

#### Data Model Generation
- Database schemas
- ORM models
- DTOs/Entities
- Validation schemas

### 2. Code Analysis Skills

#### Static Analysis
- Complexity metrics
- Code smell detection
- Dependency analysis
- Security scanning

#### Pattern Recognition
- Design patterns
- Anti-patterns
- Code duplication
- Architectural patterns

### 3. Testing Skills

#### Test Generation
- Unit tests
- Integration tests
- E2E tests
- Test fixtures

#### Test Coverage
- Coverage analysis
- Gap identification
- Coverage reports
- Test prioritization

### 4. Documentation Skills

#### Code Documentation
- Inline comments
- Function documentation
- API documentation
- Type annotations

#### Project Documentation
- README generation
- Architecture docs
- Setup guides
- Contribution guides

### 5. Refactoring Skills

#### Code Transformation
- Extract method
- Rename symbols
- Move code
- Inline variables

#### Modernization
- Update syntax
- Migrate APIs
- Update dependencies
- Apply patterns

## Skill Definition Format

### Basic Skill Structure

```yaml
skill:
  id: "skill-name"
  version: "1.0.0"
  name: "Human-readable skill name"
  description: "What this skill does"
  category: "code-generation"
  
  inputs:
    - name: "input1"
      type: "string"
      required: true
      description: "Description of input"
    - name: "input2"
      type: "object"
      required: false
      default: {}
  
  outputs:
    - name: "output1"
      type: "string"
      description: "Description of output"
  
  steps:
    - action: "step1"
      params: { }
    - action: "step2"
      params: { }
  
  examples:
    - input: { }
      output: { }
```

### Advanced Skill Structure

```yaml
skill:
  id: "generate-rest-api"
  version: "2.0.0"
  name: "REST API Generator"
  description: "Generate a complete REST API with routes, controllers, and models"
  
  metadata:
    author: "Your Name"
    tags: ["api", "rest", "backend"]
    languages: ["javascript", "typescript", "python"]
  
  inputs:
    - name: "spec"
      type: "openapi"
      required: true
      description: "OpenAPI specification"
    - name: "framework"
      type: "enum"
      values: ["express", "fastify", "flask", "fastapi"]
      required: true
    - name: "options"
      type: "object"
      schema:
        authentication: boolean
        validation: boolean
        documentation: boolean
  
  dependencies:
    - skill: "generate-models"
    - skill: "generate-validation"
  
  steps:
    - action: "parse_openapi"
      input: "spec"
      output: "parsed_spec"
    
    - action: "generate_routes"
      input: "parsed_spec"
      output: "routes"
    
    - action: "generate_controllers"
      input: "parsed_spec"
      output: "controllers"
    
    - action: "generate_models"
      input: "parsed_spec"
      output: "models"
    
    - action: "generate_tests"
      input: ["routes", "controllers"]
      output: "tests"
  
  validation:
    - check: "syntax_valid"
    - check: "tests_pass"
    - check: "linting_pass"
```

## Creating Custom Skills

### Step 1: Identify the Need

Questions to ask:
- What repetitive task could be automated?
- What expertise could be codified?
- What would help developers be more productive?

### Step 2: Define Inputs and Outputs

Be specific about what the skill needs and produces:

```yaml
inputs:
  - name: "entity_name"
    type: "string"
    description: "Name of the entity (e.g., User, Product)"
    example: "User"
  
  - name: "fields"
    type: "array"
    description: "List of fields with types"
    example:
      - name: "email"
        type: "string"
        required: true
      - name: "age"
        type: "number"
        required: false

outputs:
  - name: "model_code"
    type: "string"
    description: "Generated model code"
  
  - name: "validation_code"
    type: "string"
    description: "Generated validation schema"
```

### Step 3: Implement Steps

Break down the skill into logical steps:

```yaml
steps:
  - name: "validate_input"
    action: "validate"
    checks:
      - "entity_name is valid identifier"
      - "fields array is not empty"
  
  - name: "generate_properties"
    action: "transform"
    template: "property_template"
    foreach: "fields"
  
  - name: "generate_constructor"
    action: "template"
    template: "constructor_template"
  
  - name: "generate_methods"
    action: "generate"
    methods: ["toJSON", "validate", "save"]
  
  - name: "format_output"
    action: "format"
    formatter: "prettier"
```

### Step 4: Add Examples

Provide clear examples:

```yaml
examples:
  - name: "Simple User Model"
    input:
      entity_name: "User"
      fields:
        - { name: "email", type: "string" }
        - { name: "name", type: "string" }
    output: |
      class User {
        constructor(email, name) {
          this.email = email;
          this.name = name;
        }
        
        toJSON() {
          return {
            email: this.email,
            name: this.name
          };
        }
      }
  
  - name: "Complex Product Model"
    input:
      entity_name: "Product"
      fields:
        - { name: "id", type: "number" }
        - { name: "name", type: "string" }
        - { name: "price", type: "number" }
        - { name: "inStock", type: "boolean" }
    output: |
      // Generated complex product model code
```

## Skill Examples

### 1. CRUD Generator Skill

```yaml
skill:
  id: "crud-generator"
  name: "CRUD Operations Generator"
  description: "Generates complete CRUD operations for an entity"
  
  inputs:
    - name: "entity"
      type: "string"
    - name: "database"
      type: "enum"
      values: ["postgres", "mysql", "mongodb"]
  
  steps:
    - action: "generate_create"
      template: "create_template"
    - action: "generate_read"
      template: "read_template"
    - action: "generate_update"
      template: "update_template"
    - action: "generate_delete"
      template: "delete_template"
    - action: "generate_tests"
      template: "test_template"
```

### 2. Migration Generator Skill

```yaml
skill:
  id: "migration-generator"
  name: "Database Migration Generator"
  description: "Generates database migration scripts"
  
  inputs:
    - name: "from_schema"
      type: "object"
    - name: "to_schema"
      type: "object"
    - name: "database_type"
      type: "string"
  
  steps:
    - action: "diff_schemas"
      output: "changes"
    - action: "generate_up_migration"
      input: "changes"
    - action: "generate_down_migration"
      input: "changes"
    - action: "validate_migrations"
```

### 3. Component Generator Skill

```yaml
skill:
  id: "react-component-generator"
  name: "React Component Generator"
  description: "Generates React components with TypeScript"
  
  inputs:
    - name: "component_name"
      type: "string"
    - name: "props"
      type: "array"
    - name: "hooks"
      type: "array"
      default: []
  
  steps:
    - action: "generate_types"
      output: "prop_types"
    - action: "generate_component"
      template: "component_template"
    - action: "generate_styles"
      template: "css_module_template"
    - action: "generate_tests"
      template: "test_template"
    - action: "generate_story"
      template: "storybook_template"
```

### 4. API Documentation Skill

```yaml
skill:
  id: "api-doc-generator"
  name: "API Documentation Generator"
  description: "Generates API documentation from code"
  
  inputs:
    - name: "source_files"
      type: "array"
    - name: "format"
      type: "enum"
      values: ["openapi", "markdown", "html"]
  
  steps:
    - action: "parse_code"
      output: "parsed_endpoints"
    - action: "extract_types"
      output: "type_definitions"
    - action: "generate_examples"
      output: "example_requests"
    - action: "format_documentation"
      format: "format"
```

## Skill Composition

Skills can be combined to create powerful workflows:

```yaml
workflow:
  name: "Full Stack Feature Generator"
  description: "Generates a complete feature with frontend, backend, and tests"
  
  skills:
    - skill: "generate-models"
      output: "models"
    
    - skill: "generate-rest-api"
      input: "models"
      output: "api"
    
    - skill: "generate-react-component"
      input: "api"
      output: "component"
    
    - skill: "generate-tests"
      input: ["api", "component"]
      output: "tests"
    
    - skill: "generate-documentation"
      input: ["api", "component"]
      output: "docs"
```

## Best Practices

### 1. Design for Reusability

- Keep skills focused and single-purpose
- Make skills composable
- Use clear, consistent interfaces
- Avoid hard-coded values

### 2. Provide Clear Documentation

```yaml
skill:
  documentation:
    description: "Detailed description of what the skill does"
    usage: "How to use the skill"
    examples:
      - "Example 1"
      - "Example 2"
    limitations: "What the skill cannot do"
    related_skills: ["skill1", "skill2"]
```

### 3. Include Validation

```yaml
validation:
  input_validation:
    - check: "entity_name matches /^[A-Z][a-zA-Z0-9]*$/"
      error: "Entity name must be PascalCase"
    - check: "fields.length > 0"
      error: "Must have at least one field"
  
  output_validation:
    - check: "syntax_valid"
    - check: "follows_conventions"
```

### 4. Handle Errors Gracefully

```yaml
error_handling:
  on_invalid_input:
    action: "provide_feedback"
    message: "Clear explanation of what's wrong"
  
  on_generation_error:
    action: "retry_with_fallback"
    fallback: "simpler_template"
  
  on_validation_error:
    action: "report_and_continue"
    report_format: "structured"
```

### 5. Test Thoroughly

```yaml
tests:
  - name: "Happy path"
    input: { valid_input }
    expected_output: { expected_result }
  
  - name: "Edge case: minimal input"
    input: { minimal_input }
    expected_output: { minimal_output }
  
  - name: "Error case: invalid input"
    input: { invalid_input }
    expected_error: "Specific error message"
```

## Using Skills with Copilot

### In Chat

```
Generate a REST API for a User entity with email, name, and age fields using the crud-generator skill
```

### In Code

```typescript
// @copilot-skill: generate-component
// Component: UserProfile
// Props: user: User, onEdit: () => void
```

### In Comments

```javascript
// TODO: Use migration-generator skill to create migration from v1 to v2 schema
```

## Resources

- [Copilot Skill Development Guide](https://docs.github.com/en/copilot)
- [Skill Templates Repository](https://github.com/github/copilot-skills)
- [Community Skills](https://github.com/topics/copilot-skills)
