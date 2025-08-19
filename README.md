# KTRetrofit

KTRetrofit是一个基于HarmonyOS ArkTS开发的HTTP客户端库，灵感来源于Retrofit，提供了声明式API调用方式，简化网络请求的开发流程。

## 特性

- 声明式API定义，通过装饰器实现
- 支持常见的HTTP方法（GET, POST, PUT, DELETE等）
- 灵活的参数处理（路径参数、查询参数、请求体等）
- 基于ArkTS原生HTTP API实现
- 支持拦截器机制
- 类型安全的响应处理

## 安装

### 通过GitHub Packages远程依赖安装

KTRetrofit已发布到GitHub Packages，您可以通过以下方式安装：

1. 首先在项目根目录创建或编辑`.npmrc`文件，添加GitHub Packages配置：
   ```
   @killetom:registry=https://npm.pkg.github.com
   ```

2. 在项目的`oh-package.json5`文件中添加依赖：
   ```json5
   {
     "dependencies": {
       "@killetom/ktretrofit": "^1.0.0-alpha"
     }
   }
   ```

3. 然后执行安装命令：
   ```bash
   ohpm install
   ```

### 本地开发安装

如果您需要本地开发和修改KTRetrofit，可以直接克隆仓库进行开发：
```bash
git clone https://github.com/KilleTom/ktretrofit.git
```

## 使用示例

由于HarmonyOS对注解标记接口及抽象方法有限制，KTRetrofit主要提供**无注解配置方式**来实现API调用。

### 1. 定义API接口

#### 1.1 无注解配置方式

```typescript
import { ApiServiceConfig, ApiParameterConfig } from '@killetom/ktretrofit/src/main/ets/retrofit/config/ApiConfig';
import { HttpParameterType } from '@killetom/ktretrofit/src/main/ets/retrofit/http/param/HttpParameterType';
import { HttpMethod } from '@killetom/ktretrofit/src/main/ets/retrofit/http/method/HttpMethod';
import { Call } from '@killetom/ktretrofit/src/main/ets/retrofit/call/Call';

// 用户模型
interface User {
  id: number;
  name: string;
  email: string;
}

// 用户创建请求
interface CreateUserRequest {
  name: string;
  email: string;
  password: string;
}

// 定义服务接口（仅用于类型安全）
interface UserService {
  getUsers(page: number, limit: number): Call<User[]>;
  getUserById(id: number): Call<User>;
  createUser(user: CreateUserRequest): Call<User>;
  updateUser(id: number, user: Partial<User>): Call<User>;
  deleteUser(id: number): Call<void>;
}

// 创建用户服务配置（替代注解方式）
function createUserServiceConfig(): ApiServiceConfig<UserService> {
  // 定义路径参数配置
  const pathIdParam: ApiParameterConfig = {
    type: HttpParameterType.PATH,
    name: 'id'
  };

  // 定义查询参数配置
  const queryPageParam: ApiParameterConfig = {
    type: HttpParameterType.QUERY,
    name: 'page'
  };

  const queryLimitParam: ApiParameterConfig = {
    type: HttpParameterType.QUERY,
    name: 'limit'
  };

  // 定义请求体参数配置
  const bodyParam: ApiParameterConfig = {
    type: HttpParameterType.BODY
  };

  // 创建服务配置
  const config: ApiServiceConfig<UserService> = {
    // 设置服务名称以匹配接口名称，以便更好的日志和错误信息
    serviceName: 'UserService',
    methods: {
      // GET /users?page={page}&limit={limit}
      "getUsers": {
        method: HttpMethod.GET,
        path: '/users',
        parameters: {
          0: queryPageParam,  // 第一个参数是页码
          1: queryLimitParam  // 第二个参数是每页数量
        }
      },

      // PATCH /users/{id}
      "getUserById": {
        method: HttpMethod.PATCH,
        path: '/users/{id}',
        parameters: {
          0: pathIdParam  // 第一个参数是路径ID
        }
      },

      // POST /users
      "createUser": {
        method: HttpMethod.POST,
        path: '/users',
        parameters: {
          0: bodyParam  // 第一个参数是请求体
        }
      },

      // PUT /users/{id}
      "updateUser": {
        method: HttpMethod.PUT,
        path: '/users/{id}',
        parameters: {
          0: pathIdParam,  // 第一个参数是路径ID
          1: bodyParam     // 第二个参数是请求体
        }
      },

      // DELETE /users/{id}
      "deleteUser": {
        method: HttpMethod.DELETE,
        path: '/users/{id}',
        parameters: {
          0: pathIdParam  // 第一个参数是路径ID
        }
      }
    }
  };

  return config;
}
```
### 2. 创建Retrofit实例并使用

#### 2.1 无注解配置方式

```typescript
import { createRetrofit } from '@killetom/ktretrofit';
import { UserService, createUserServiceConfig } from './UserService';

// 创建Retrofit实例
const retrofit = createRetrofit('https://api.example.com')
  // 添加全局请求头
  .addHeader('Content-Type', 'application/json')
  .addHeader('Accept', 'application/json')
  // 设置超时时间（毫秒）
  .setConnectTimeout(30000)
  .setReadTimeout(60000)
  // 构建Retrofit实例
  .build();

// 创建API服务配置
const userServiceConfig = createUserServiceConfig();

// 使用配置创建API服务实例
const userService = retrofit.configService(userServiceConfig);

// 调用API方法示例（同步执行）
function getUsersExample(page: number = 1, limit: number = 10) {
  try {
    const call = userService.getUsers(page, limit);
    const response = call.execute();
    
    // 使用getNotNullBody()简化错误处理
    const users = response.getNotNullBody();
    
    console.log('使用配置方式获取用户列表成功:', users);
    return users;
  } catch (error) {
    console.error('使用配置方式获取用户列表失败:', error);
    throw error instanceof Error ? error : new Error(String(error));
  }
}

// 创建新用户示例
function createUserExample(userData: CreateUserRequest) {
  try {
    const call = userService.createUser(userData);
    const response = call.execute();
    
    const newUser = response.getNotNullBody();
    console.log('使用配置方式创建用户成功:', newUser);
    return newUser;
  } catch (error) {
    console.error('使用配置方式创建用户失败:', error);
    throw error instanceof Error ? error : new Error(String(error));
  }
}

// 高级功能示例：请求配置扩展
function getUserWithCustomHeaders(id: number, authToken: string) {
  try {
    // 先获取标准调用对象
    const standardCall = userService.getUserById(id);
    
    // 创建自定义调用对象，添加额外的请求头
    const customCall = standardCall.clone()
      .addHeader('Authorization', `Bearer ${authToken}`)
      .addHeader('X-Request-ID', `req-${Date.now()}`);
    
    // 执行自定义请求
    const response = customCall.execute();
    
    return response.getNotNullBody();
  } catch (error) {
    console.error('获取用户失败:', error);
    throw error;
  }
}

// 执行示例
// const users = getUsersExample(1, 10);
// const newUser = createUserExample({ name: '测试用户', email: 'test@example.com', password: 'secure_password' });
// const userWithHeaders = getUserWithCustomHeaders(1, 'your-auth-token');
```

## 配置类型映射表

由于HarmonyOS对注解有限制，KTRetrofit主要使用配置对象来定义API。以下是配置类型与原注解的映射关系：

### HTTP方法类型
- `HttpMethod.GET` - 对应原`@GET`注解
- `HttpMethod.POST` - 对应原`@POST`注解
- `HttpMethod.PUT` - 对应原`@PUT`注解
- `HttpMethod.DELETE` - 对应原`@DELETE`注解
- `HttpMethod.PATCH` - 对应原`@PATCH`注解
- `HttpMethod.HEAD` - 对应原`@HEAD`注解
- `HttpMethod.OPTIONS` - 对应原`@OPTIONS`注解

### 参数类型
- `HttpParameterType.PATH` - 对应原`@Path`注解
- `HttpParameterType.QUERY` - 对应原`@Query`注解
- `HttpParameterType.QUERY_MAP` - 对应原`@QueryMap`注解
- `HttpParameterType.BODY` - 对应原`@Body`注解
- `HttpParameterType.HEADER` - 对应原`@Header`注解
- `HttpParameterType.HEADER_MAP` - 对应原`@HeaderMap`注解
- `HttpParameterType.FIELD` - 对应原`@Field`注解（用于表单）
- `HttpParameterType.FIELD_MAP` - 对应原`@FieldMap`注解（用于表单）
- `HttpParameterType.PART` - 对应原`@Part`注解（用于多部分请求）
- `HttpParameterType.PART_MAP` - 对应原`@PartMap`注解（用于多部分请求）
- `HttpParameterType.URL` - 对应原`@Url`注解
- `HttpParameterType.COOKIE` - 对应原`@Cookie`注解

### 请求类型配置
- `requestType: 'FORM_URL_ENCODED'` - 对应原`@FormUrlEncoded`注解
- `requestType: 'MULTIPART'` - 对应原`@Multipart`注解

## 配置方式使用示例

### 基本用法（替代注解方式）

```typescript
import { ApiServiceConfig, ApiParameterConfig } from '@killetom/ktretrofit/src/main/ets/retrofit/config/ApiConfig';
import { HttpParameterType } from '@killetom/ktretrofit/src/main/ets/retrofit/http/param/HttpParameterType';
import { HttpMethod } from '@killetom/ktretrofit/src/main/ets/retrofit/http/method/HttpMethod';
import { Call } from '@killetom/ktretrofit/src/main/ets/retrofit/call/Call';

// 定义服务接口（仅用于类型安全）
interface ApiService {
  // 基本GET请求
  getUsers(): Call<any[]>;
  
  // 带查询参数的GET请求
  searchItems(query: string, page?: number, sort?: string): Call<any[]>;
  
  // 带路径参数的GET请求
  getUserById(id: number): Call<any>;
  
  // 带请求体的POST请求
  createUser(user: any): Call<any>;
  
  // 带路径参数和请求体的PUT请求
  updateUser(id: number, user: any): Call<any>;
  
  // 带路径参数的DELETE请求
  deleteUser(id: number): Call<void>;
  
  // 带请求头的请求
  getProtectedData(token: string): Call<any>;
}

// 创建API服务配置
function createApiServiceConfig(): ApiServiceConfig<ApiService> {
  // 定义参数配置
  const pathIdParam: ApiParameterConfig = { type: HttpParameterType.PATH, name: 'id' };
  const queryQueryParam: ApiParameterConfig = { type: HttpParameterType.QUERY, name: 'query' };
  const queryPageParam: ApiParameterConfig = { type: HttpParameterType.QUERY, name: 'page' };
  const querySortParam: ApiParameterConfig = { type: HttpParameterType.QUERY, name: 'sort' };
  const bodyParam: ApiParameterConfig = { type: HttpParameterType.BODY };
  const headerAuthParam: ApiParameterConfig = { type: HttpParameterType.HEADER, name: 'Authorization' };
  
  // 创建服务配置
  const config: ApiServiceConfig<ApiService> = {
    serviceName: 'ApiService',
    methods: {
      'getUsers': {
        method: HttpMethod.GET,
        path: '/users'
      },
      'searchItems': {
        method: HttpMethod.GET,
        path: '/search',
        parameters: {
          0: queryQueryParam,
          1: queryPageParam,
          2: querySortParam
        }
      },
      'getUserById': {
        method: HttpMethod.GET,
        path: '/users/{id}',
        parameters: {
          0: pathIdParam
        }
      },
      'createUser': {
        method: HttpMethod.POST,
        path: '/users',
        parameters: {
          0: bodyParam
        }
      },
      'updateUser': {
        method: HttpMethod.PUT,
        path: '/users/{id}',
        parameters: {
          0: pathIdParam,
          1: bodyParam
        }
      },
      'deleteUser': {
        method: HttpMethod.DELETE,
        path: '/users/{id}',
        parameters: {
          0: pathIdParam
        }
      },
      'getProtectedData': {
        method: HttpMethod.GET,
        path: '/protected',
        parameters: {
          0: headerAuthParam
        }
      }
    }
  };
  
  return config;
}
```
## 实际项目使用示例

### 创建API服务管理类

```typescript
import { createRetrofit } from '@killetom/ktretrofit';
import { UserService, createUserServiceConfig } from './services/UserService';
import { ProductService, createProductServiceConfig } from './services/ProductService';

/**
 * API服务管理类，集中管理所有API服务实例
 */
export class ApiManager {
  private static instance: ApiManager;
  private retrofit = createRetrofit('https://api.your-app.com')
    .addHeader('Content-Type', 'application/json')
    .addHeader('Accept', 'application/json')
    .setConnectTimeout(30000)
    .setReadTimeout(60000)
    .build();
  
  // API服务实例
  private userService: UserService;
  private productService: ProductService;
  
  private constructor() {
    // 使用配置方式创建服务实例
    this.userService = this.retrofit.configService(createUserServiceConfig());
    this.productService = this.retrofit.configService(createProductServiceConfig());
  }
  
  public static getInstance(): ApiManager {
    if (!ApiManager.instance) {
      ApiManager.instance = new ApiManager();
    }
    return ApiManager.instance;
  }
  
  // 获取用户服务
  public getUserService(): UserService {
    return this.userService;
  }
  
  // 获取产品服务
  public getProductService(): ProductService {
    return this.productService;
  }
  
  // 设置认证令牌
  public setAuthToken(token: string): void {
    // 创建新的Retrofit实例并重新创建所有服务
    this.retrofit = createRetrofit('https://api.your-app.com')
      .addHeader('Content-Type', 'application/json')
      .addHeader('Accept', 'application/json')
      .addHeader('Authorization', `Bearer ${token}`)
      .setConnectTimeout(30000)
      .setReadTimeout(60000)
      .build();
    
    // 重新创建所有服务实例
    this.userService = this.retrofit.configService(createUserServiceConfig());
    this.productService = this.retrofit.configService(createProductServiceConfig());
  }
}
```

### 在应用中使用

```typescript
import { ApiManager } from './ApiManager';

/**
 * 用户管理模块
 */
export class UserManager {
  private apiManager = ApiManager.getInstance();
  
  /**
   * 获取用户列表并显示在UI上
   * @param page 当前页码
   * @param limit 每页数量
   */
  public loadUsers(page: number = 1, limit: number = 10): void {
    try {
      // 显示加载指示器
      this.showLoading(true);
      
      // 调用API服务（同步方式）
      const call = this.apiManager.getUserService().getUsers(page, limit);
      const response = call.execute();
      
      // 使用getNotNullBody()简化错误处理
      const users = response.getNotNullBody();
      
      // 处理成功响应
      this.updateUserList(users);
      
      // 保存到本地缓存（可选）
      this.cacheUsers(users);
      
    } catch (error) {
      // 处理错误
      this.handleError(error);
    } finally {
      // 隐藏加载指示器
      this.showLoading(false);
    }
  }
  
  /**
   * 异步获取用户列表
   * @param page 当前页码
   * @param limit 每页数量
   */
  public async loadUsersAsync(page: number = 1, limit: number = 10): Promise<void> {
    try {
      // 显示加载指示器
      this.showLoading(true);
      
      // 调用API服务（异步方式）
      const call = this.apiManager.getUserService().getUsers(page, limit);
      const response = await call.enqueue();
      
      // 处理响应
      if (response.isSuccessful()) {
        const users = response.body;
        this.updateUserList(users);
        this.cacheUsers(users);
      } else {
        throw new Error(`请求失败，状态码: ${response.code}`);
      }
      
    } catch (error) {
      // 处理错误
      this.handleError(error);
    } finally {
      // 隐藏加载指示器
      this.showLoading(false);
    }
  }
  
  /**
   * 用户登录方法
   * @param username 用户名
   * @param password 密码
   */
  public login(username: string, password: string): boolean {
    try {
      const call = this.apiManager.getUserService().login({
        username,
        password
      });
      const response = call.execute();
      
      const loginResult = response.getNotNullBody();
      
      if (loginResult.token) {
        // 保存令牌
        this.saveToken(loginResult.token);
        // 设置认证令牌到API管理器
        this.apiManager.setAuthToken(loginResult.token);
        return true;
      }
      return false;
    } catch (error) {
      console.error('Login failed:', error);
      throw error instanceof Error ? error : new Error(String(error));
    }
  }
  
  // 其他辅助方法...
  private showLoading(show: boolean): void {
    // 实现显示/隐藏加载指示器
  }
  
  private updateUserList(users: any[]): void {
    // 实现更新UI显示用户列表
  }
  
  private cacheUsers(users: any[]): void {
    // 实现本地缓存用户数据
  }
  
  private handleError(error: any): void {
    // 实现错误处理逻辑
    console.error('API request failed:', error);
    // 显示错误提示给用户
  }
  
  private saveToken(token: string): void {
    // 实现保存令牌到安全存储
  }
}
```

## 构建配置

KTRetrofit使用以下系统API：
- @ohos.net.http (1.0.0)
- @ohos.util (1.0.0)
- @ohos.file.fs (1.0.0)
- @ohos.app.ability.common (1.0.0)

## 贡献

欢迎提交问题和Pull Request来帮助改进这个库。提交前请确保：

1. 遵循现有的代码风格和命名规范
2. 添加适当的测试用例
3. 更新相关文档

## 许可证

KTRetrofit使用Apache License 2.0开源许可证。您可以自由使用、修改和分发本库。