---
description: Create a feature branch following Git naming conventions and create a pull request with description
---

# Feature Branch Workflow

This workflow automates the process of creating a feature branch with proper Git naming conventions and creating a pull request with a descriptive message.

## Steps

1. **Create a new feature branch**
   ```bash
   git checkout -b feature/descriptive-name
   ```
   - Use `feature/` prefix for new features
   - Use kebab-case for branch names
   - Be descriptive but concise (e.g., `feature/document-management-system`)

2. **Make your changes**
   - Implement your feature
   - Commit changes with clear messages
   - Test your changes

3. **Push the branch to remote**
   ```bash
   git push -u origin feature/descriptive-name
   ```

4. **Create a pull request**
   - Go to GitHub repository
   - Click "New Pull Request"
   - Select your feature branch
   - Fill in the PR template with:
     - Clear title describing the feature
     - Detailed description of changes
     - Related issue numbers (if any)
     - Testing instructions
     - Screenshots (if applicable)

## Branch Naming Conventions

- `feature/` - New features
- `bugfix/` - Bug fixes
- `hotfix/` - Urgent production fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation changes
- `test/` - Test additions or modifications

## Example

```bash
# Create feature branch
git checkout -b feature/user-authentication

# Make changes and commit
git add .
git commit -m "Implement user authentication with Devise"

# Push to remote
git push -u origin feature/user-authentication

# Create PR on GitHub with description
```
