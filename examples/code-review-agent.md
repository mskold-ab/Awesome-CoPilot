# Example: Simple Code Review Agent

This example demonstrates a basic code review agent that can be used with GitHub Copilot.

## Agent Configuration

```json
{
  "name": "code-review-agent",
  "version": "1.0.0",
  "description": "Performs automated code reviews focusing on code quality and best practices",
  "instructions": "You are a senior software engineer performing code reviews. Focus on:\n\n1. Code quality and readability\n2. Potential bugs or logic errors\n3. Performance considerations\n4. Security vulnerabilities\n5. Best practices for the language/framework\n\nProvide constructive feedback with specific suggestions for improvement. Rate each issue as: Critical, Major, Minor, or Suggestion.\n\nFormat your review as:\n\n## Summary\n[Brief overview]\n\n## Issues Found\n### [Severity] - [Title]\n**Location**: File:Line\n**Issue**: [Description]\n**Suggestion**: [How to fix]\n**Example**: [Code example if applicable]\n\n## Positive Observations\n[Good practices found]\n\n## Overall Assessment\n[Final thoughts and recommendation]",
  "tools": [
    "file_reader",
    "code_analyzer",
    "git_diff"
  ],
  "triggers": {
    "events": ["pull_request_opened", "pull_request_updated"],
    "keywords": ["@review", "/review"]
  },
  "settings": {
    "model": "gpt-4",
    "max_tokens": 4096,
    "temperature": 0.3
  }
}
```

## Usage Example

### In a Pull Request

Comment on a PR:
```
@code-review-agent Please review this pull request
```

### In Code Editor

Add a comment in your code:
```javascript
// @code-review-agent Review this function
function processUserData(data) {
  // Function implementation
}
```

### Expected Output

```markdown
## Summary
Reviewed 5 files with 247 lines of changes. Found 3 issues requiring attention and several suggestions for improvement.

## Issues Found

### Major - Potential SQL Injection Vulnerability
**Location**: src/database.js:45
**Issue**: User input is directly concatenated into SQL query without sanitization
**Suggestion**: Use parameterized queries or an ORM to prevent SQL injection
**Example**:
\`\`\`javascript
// Instead of:
const query = `SELECT * FROM users WHERE id = ${userId}`;

// Use:
const query = 'SELECT * FROM users WHERE id = ?';
db.query(query, [userId]);
\`\`\`

### Minor - Missing Error Handling
**Location**: src/api/users.js:23
**Issue**: Async function doesn't handle potential errors
**Suggestion**: Add try-catch block or .catch() handler
**Example**:
\`\`\`javascript
try {
  const user = await fetchUser(id);
  return user;
} catch (error) {
  logger.error('Failed to fetch user:', error);
  throw new NotFoundError('User not found');
}
\`\`\`

### Suggestion - Consider Using const
**Location**: src/utils/helpers.js:12
**Issue**: Variable is declared with 'let' but never reassigned
**Suggestion**: Use 'const' for variables that aren't reassigned

## Positive Observations
- Good use of TypeScript types throughout
- Well-structured error handling in most modules
- Clear and descriptive function names
- Comprehensive unit tests included

## Overall Assessment
The code is generally well-written with good structure. Address the SQL injection vulnerability before merging. Other issues are minor improvements that can be addressed in follow-up commits.

**Recommendation**: Request changes for security issue, approve after fix.
```

## Integration with GitHub Actions

Create `.github/workflows/code-review.yml`:

```yaml
name: Automated Code Review
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Run Code Review Agent
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          npx copilot-agent review \
            --agent code-review-agent \
            --pr ${{ github.event.pull_request.number }} \
            --output review-comments.json
      
      - name: Post Review Comments
        uses: actions/github-script@v6
        with:
          script: |
            const fs = require('fs');
            const comments = JSON.parse(fs.readFileSync('review-comments.json', 'utf8'));
            
            for (const comment of comments) {
              await github.rest.pulls.createReviewComment({
                owner: context.repo.owner,
                repo: context.repo.repo,
                pull_number: context.payload.pull_request.number,
                body: comment.body,
                path: comment.path,
                line: comment.line
              });
            }
```

## Customization

### Focus on Specific Languages

```json
{
  "instructions": "You are a Python expert reviewing code. Focus on:\n- PEP 8 style compliance\n- Type hints usage\n- Pythonic idioms\n- Common Python anti-patterns\n- Security issues specific to Python",
  "settings": {
    "file_patterns": ["**/*.py"],
    "exclude_patterns": ["**/test_*.py", "**/tests/**"]
  }
}
```

### Security-Focused Review

```json
{
  "name": "security-review-agent",
  "instructions": "You are a security expert. Review code for:\n- Input validation issues\n- Authentication/authorization problems\n- SQL injection, XSS, CSRF vulnerabilities\n- Sensitive data exposure\n- Insecure dependencies\n- Cryptography misuse",
  "tools": [
    "security_scanner",
    "dependency_checker",
    "secret_scanner"
  ]
}
```

### Performance-Focused Review

```json
{
  "name": "performance-review-agent",
  "instructions": "You are a performance optimization expert. Review for:\n- Algorithmic complexity issues\n- Database query optimization\n- Memory leaks\n- Unnecessary computations\n- Caching opportunities\n- Async/await usage",
  "tools": [
    "profiler",
    "complexity_analyzer"
  ]
}
```

## Tips for Effective Agent Usage

1. **Be Specific**: Tell the agent what to focus on
   ```
   @code-review-agent Focus on security vulnerabilities in the authentication code
   ```

2. **Provide Context**: Give the agent relevant information
   ```
   @code-review-agent This refactors our payment processing. Review for data integrity and error handling.
   ```

3. **Iterative Reviews**: Use the agent multiple times during development
   - Initial review on draft PR
   - Follow-up review after addressing issues
   - Final review before merge

4. **Combine with Human Review**: Use agent reviews as a first pass, but always have human reviewers for critical code

5. **Learn from Reviews**: Pay attention to patterns in agent feedback to improve your coding practices
