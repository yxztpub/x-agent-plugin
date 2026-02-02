---
name: backend-dev
description: "进行golang后端api开发及中间件使用时需遵循的代码开发规范指南"
---
# API Design and Middleware Best Practices

Based on the analysis of the typical API function patterns and the overall architecture of the system, this document outlines the best practices for API design, middleware usage, data structures, and system integration patterns.

## 1. Full Stack Architecture Pattern

The application follows a layered architecture with clear separation of concerns:

### 1.1 Route Layer (Controller)
- Located in controller files under `internal/` directory
- Handles HTTP routing and request/response binding
- Uses Gin framework for routing and middleware
- Implements consistent error handling with `httputil.NewError()`

```go
func (c *Controller) BusinessFunctionStart(ctx *gin.Context) {
    var req BusinessFunctionStartReq
    if err := ctx.ShouldBindJSON(&req); err != nil {
        httputil.NewError(ctx, http.StatusBadRequest, err)
        return
    }

    err := service.NewBusinessService().BusinessFunctionStart(ctx, req.BusinessId, req.Creator, req.BeginTime, req.EndTime)
    if err != nil {
        httputil.NewError(ctx, http.StatusInternalServerError, err)
        return
    }

    result := httputil.NewResult()
    ctx.JSON(http.StatusOK, StringResult{
        HttpResult: result,
        Result:     "ok",
    })
}
```

### 1.2 API Layer (Request/Response Models)
- Located in controller files under `internal/` directory
- Defines request and response structures
- Implements data validation through JSON tags
- Uses generic result types for consistent response format

```go
type BusinessFunctionStartReq struct {
    BusinessId string `json:"businessId"`
    Creator    string `json:"creator"`
    BeginTime  string `json:"beginTime"`
    EndTime    string `json:"endTime"`
}

type StringResult struct {
    httputil.HttpResult
    Result string `json:"result,omitempty"`
}
```

### 1.3 Service Layer
- Located in service files under `internal/` directory
- Contains business logic and orchestrates operations
- Handles transactions and complex operations
- Integrates with external services asynchronously

```go
func (s BusinessService) BusinessFunctionStart(ctx context.Context, businessId string, creator string, beginTime string, endTime string) error {
    // Validation and business logic
    records, err := dao.BusinessEntityDao{}.FindByBusinessID(ctx, businessId)
    if err != nil {
        return nil
    }

    // Create business task record
    taskId, err := dao.BusinessEntityDao{}.Save(ctx, data.BusinessEntity{
        TenantCode: util.GetTenantCode(ctx),
        BusinessID: businessId,
        // ... other fields
    })
    if err != nil {
        return err
    }

    // Async processing to external service
    util.EasyGo(util.NewTenantContext(ctx), "BusinessTask", func() {
        req := manager.BusinessFunctionReq{
            TaskId:       taskId,
            BusinessId:   businessId,
            Version:      versionValue,
            BeginTime:    beginTime,
            EndTime:      endTime,
        }
        err := manager.NewExternalServiceClient().BusinessFunction(util.NewTenantContext(ctx), req)
        if err != nil {
            config.Logger.WithContext(ctx).Errorf("发起业务请求失败: %v", err)
            // Update task status as failed
            _ = dao.BusinessEntityDao{}.UpdateStatus(ctx, taskId, 2, "sys")
        }
    })

    return nil
}
```

### 1.4 DAO Layer (Data Access Object)
- Located in `datasource/dao/` directory
- Handles database operations with consistent error logging
- Uses GORM with context for database operations
- Implements CRUD operations with proper filtering and ordering

```go
func (o BusinessEntityDao) Save(ctx context.Context, task data.BusinessEntity) (int64, error) {
    if task.TenantCode == "" {
        task.TenantCode = "-1"
    }
    err := ob.GetDB().WithContext(ctx).Save(&task).Error

    if err != nil {
        config.Logger.Errorf("BusinessEntityDao_save fail %v", err)
    }
    return task.ID, err
}
```

### 1.5 Data Layer (Models)
- Located in data files under `internal/` directory
- Defines database entity structures
- Uses consistent naming and JSON tags
- Includes audit fields (Creator, GmtCreated, etc.)

```go
type BusinessEntity struct {
    ID         int64     `json:"id"`
    TenantCode string    `json:"tenantCode"`
    BusinessID string    `json:"business_id"`
    Version    int       `json:"version"`
    Category   int       `json:"category"`
    VersionNum int       `json:"version_num"`
    Name       string    `json:"name"`
    Status     int       `json:"status"`

    IsDeleted   string    `json:"isDeleted"`
    Creator     string    `json:"creator"`
    GmtCreated  time.Time `json:"gmtCreated"`
    Modifier    string    `json:"modifier"`
    GmtModified time.Time `json:"gmtModified"`
}
```

## 2. Context Usage Best Practices

### 2.1 Context Propagation
- Always pass context through all layers
- Use `util.NewTenantContext(ctx)` for background goroutines
- Extract tenant code using `util.GetTenantCode(ctx)`
- Include trace IDs for distributed tracing

### 2.2 Context Values
- Tenant information stored in context for multi-tenancy
- Trace IDs for debugging and monitoring
- User information for authorization

## 3. Logging Best Practices

### 3.1 Structured Logging
- Use `config.Logger.WithContext(ctx)` for contextual logging
- Include relevant identifiers in log messages
- Differentiate between Info, Error, and Debug levels

```go
config.Logger.WithContext(ctx).Infof("OpQualityAnalysisClusterTaskDao_FindByPlanID success planId=%s, count=%d", planId, len(tasks))
config.Logger.WithContext(ctx).Errorf("发起聚类请求失败: %v", err)
```

### 3.2 Log Message Format
- Include operation identifiers and key parameters
- Log both successful and failed operations
- Use consistent formatting across the application

## 4. Error Handling Patterns

### 4.1 HTTP Error Responses
- Use `httputil.NewError()` for consistent error formatting
- Map application errors to appropriate HTTP status codes
- Include error details in response

### 4.2 Business Logic Errors
- Return Go errors from service and DAO layers
- Use `errors.New()` and `errors.Wrap()` for error wrapping
- Handle specific error cases appropriately

## 5. Middleware Usage

### 5.1 Built-in Middleware
- CORS: `r.Use(cors.Default())`
- OpenTelemetry: `r.Use(otelgin.Middleware())`
- Logging: `r.Use(httputil.Logging())`
- Authentication: `r.Use(httputil.Auth())`

### 5.2 Custom Middleware Patterns
- Request logging with body content
- Tenant identification and validation
- Rate limiting and security checks

## 6. Database Access Patterns

### 6.1 GORM Usage
- Use `WithContext(ctx)` for all database operations
- Implement soft deletes with `is_deleted` field
- Use consistent WHERE clauses with `AND is_deleted = 'N'`

### 6.2 Query Optimization
- Use indexes appropriately
- Implement pagination for large datasets
- Use transaction boundaries for complex operations

## 7. External Service Integration

### 7.1 HTTP Client Patterns
- Use `httputil.PostWithCtx()` for external calls
- Include tenant headers in external requests
- Handle timeouts and retries appropriately

### 7.2 Asynchronous Processing
- Use `util.EasyGo()` for fire-and-forget operations
- Handle errors in background goroutines
- Update status asynchronously for long-running tasks

## 8. Data Validation and Security

### 8.1 Input Validation
- Use Gin's binding for JSON validation
- Validate required fields and data formats
- Implement custom validation when needed

### 8.2 Security Considerations
- Sanitize user inputs
- Use parameterized queries to prevent SQL injection
- Implement proper authentication and authorization

## 9. Redis Usage Patterns

### 9.1 Distributed Locking
- Use `redis.Lock()` for distributed synchronization
- Implement proper lock release mechanisms
- Handle lock acquisition failures gracefully

## 10. Response Format Consistency

### 10.1 Standard Response Structure
- Use `HttpResult` as base for all responses
- Include `ReturnCode`, `ReturnMsg`, and `Success` fields
- Use generic `CommonResult[T]` for typed responses

### 10.2 Success vs Error Responses
- Return 200 for all API calls regardless of business success
- Use `ReturnCode` to indicate business-level success/failure
- Include detailed error messages when appropriate

## 11. Performance Considerations

### 11.1 Background Processing
- Use goroutines for non-blocking operations
- Implement proper error handling in background tasks
- Consider resource usage and concurrency limits

### 11.2 Database Performance
- Use connection pooling
- Implement caching where appropriate
- Optimize queries with proper indexing

## 12. Testing and Maintainability

### 12.1 Testable Architecture
- Keep business logic separate from HTTP concerns
- Use interfaces for dependency injection
- Implement proper mocking for external services

### 12.2 Code Organization
- Follow consistent naming conventions
- Use descriptive function and variable names
- Organize code by domain and responsibility