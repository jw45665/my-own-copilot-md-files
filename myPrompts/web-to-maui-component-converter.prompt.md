---
mode: 'agent'
tools: ['changes', 'codebase', 'editFiles', 'problems']
description: 'Convert Web Blazor components to MAUI-compatible components with proper service patterns and URL handling'
---

# MyCommunityProject Web-to-MAUI Component Converter

Your goal is to convert existing Web Blazor components from CommunityPlattform to MAUI-compatible components in MauiBlazorWeb.Shared, following the project's Clean Architecture patterns.

## Project Architecture Context

MyCommunityProject uses a Clean Architecture with separate service implementations:
- **Web (CommunityPlattform)**: Uses `CommunityBlogService` with direct EF Core access
- **MAUI (MauiBlazorWeb.Shared)**: Uses `HttpBlogService` with REST API calls
- **Interface**: Both implement `IBlogService` for abstraction

## Critical Conversion Rules

### Service Layer Transformation
- **REMOVE**: `@inject ApplicationDbContext` (Web-only)
- **ADD**: `@inject IBlogService _blogService` (Cross-platform)
- **REPLACE**: Direct EF queries with service method calls
- **TRANSFORM**: Entity objects to DTO objects from API responses

### URL and Resource Handling
- **Images**: Implement `GetAbsoluteImageUrl(string? imageUrl)` method
- **Transform**: Relative URLs (`/images/...`) to absolute URLs for MAUI
- **Static Files**: Use `_content/MauiBlazorWeb.Shared/` prefix for RCL resources
- **Error Handling**: Add `onerror` fallbacks for image loading

### Data Access Pattern Conversion
```csharp
// WEB PATTERN (remove)
@inject ApplicationDbContext _context
var article = await _context.Articles
    .Where(x => x.Id == id)
    .Include(a => a.Comments)
    .FirstOrDefaultAsync();

// MAUI PATTERN (implement)
@inject IBlogService _blogService
var article = await _blogService.GetArticleByIdAsync(id);
```

### Component Structure Requirements
- **File Location**: `MauiBlazorWeb.Shared/Pages/` or `MauiBlazorWeb.Shared/Components/`
- **Isolation**: Use scoped CSS (`.razor.css` files) for component-specific styles
- **JavaScript**: Component-specific JS in separate `.js` files with IJSRuntime
- **Documentation**: Create corresponding `.md` file in `/docs/Components/`

## Data Type Transformations

### Entity to DTO Mapping
- `Article` entity → `ArticleDto` / `BlogPostDto`
- `Comment` entity → `CommentDto`
- `Category` entity → `CategoryDto`
- Include navigation properties as nested DTOs

### API Response Handling
- Wrap service calls in try-catch blocks
- Use `ApiResponse<T>` wrapper types
- Handle loading states with boolean flags
- Implement proper error messages for users

## HTTP Service Integration

### Available Service Methods
```csharp
Task<BlogPostDto[]> GetFeaturedArticlesAsync(CancellationToken cancellationToken = default);
Task<BlogPostDto> GetArticleByIdAsync(int id, CancellationToken cancellationToken = default);
Task<CategoryDto[]> GetCategoriesAsync(CancellationToken cancellationToken = default);
Task<CommentDto[]> GetCommentsAsync(int articleId, CancellationToken cancellationToken = default);
```

### Error Handling Pattern
```csharp
private bool isLoading = true;
private string? errorMessage = null;

try 
{
    isLoading = true;
    var result = await _blogService.GetArticleByIdAsync(id);
    // Process result
}
catch (Exception ex)
{
    errorMessage = "Fehler beim Laden der Daten.";
    // Log exception
}
finally
{
    isLoading = false;
    StateHasChanged();
}
```

## URL Transformation Implementation

### Required Method
```csharp
private string GetAbsoluteImageUrl(string? imageUrl)
{
    if (string.IsNullOrEmpty(imageUrl))
        return "/img/placeholder.jpg";
    
    // MAUI requires absolute URLs
    if (imageUrl.StartsWith("/"))
        return $"https://localhost:7001{imageUrl}";
    
    return imageUrl;
}
```

### Usage in Templates
```html
<!-- Before (Web) -->
<img src="@article.FeaturedImage" alt="@article.Title" />

<!-- After (MAUI) -->
<img src="@GetAbsoluteImageUrl(article.FeaturedImage)" 
     alt="@article.Title"
     onerror="this.src='/img/placeholder.jpg'" />
```

## Component Lifecycle Adjustments

### Authentication Handling
- Use `AuthenticationStateProvider` for user state
- Handle unauthenticated scenarios gracefully
- Implement proper authorization checks before API calls

### State Management
- Use component-level state management
- Implement loading indicators
- Handle async operations properly with CancellationToken

## Validation and Best Practices

### Before Conversion
1. **MANDATORY**: Run `file_search` to check existing MAUI components
2. **VERIFY**: IBlogService interface has required methods
3. **CONFIRM**: Target directory structure in MauiBlazorWeb.Shared

### After Conversion
1. **TEST**: Component loads without EF dependencies
2. **VERIFY**: Images display correctly with absolute URLs
3. **CHECK**: API calls work with proper error handling
4. **VALIDATE**: Authentication flows work on MAUI platforms

### Anti-Patterns to Avoid
- Using `@inject ApplicationDbContext` in MAUI components
- Direct entity model usage instead of DTOs
- Relative image URLs without transformation
- Shared .razor files between Web and MAUI for database content
- Missing error handling for HTTP API calls

## Conversion Workflow

1. **Analyze**: Identify all EF dependencies and direct database access
2. **Plan**: Map entity operations to IBlogService methods
3. **Transform**: Replace service injections and data access patterns
4. **Implement**: Add URL transformation and error handling
5. **Test**: Verify component works independently of EF context
6. **Document**: Update component documentation with MAUI-specific notes