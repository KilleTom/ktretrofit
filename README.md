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

### 通过远程依赖安装

在项目的`oh-package.json5`文件中添加依赖：

```json5
{
  "dependencies": {
    "ktretrofit": "^v1.0.0-alpha"
  }
}
```

然后执行安装命令：

```bash
ohpm install
```

## 使用示例

### 1. 定义API接口

```typescript
import { GET, POST, DELETE, PUT, Path, Query, Body } from 'ktretrofit';

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

// 用户API服务接口
interface UserService {
  @GET('/users')
  getUsers(@Query('page') page: number, @Query('limit') limit: number): Promise<User[]>;

  @GET('/users/{id}')
  getUserById(@Path('id') id: number): Promise<User>;

  @POST('/users')
  createUser(@Body() user: CreateUserRequest): Promise<User>;

  @PUT('/users/{id}')
  updateUser(@Path('id') id: number, @Body() user: Partial<User>): Promise<User>;

  @DELETE('/users/{id}')
  deleteUser(@Path('id') id: number): Promise<void>;
}
```

### 2. 创建Retrofit实例并使用

```typescript
import { createRetrofit } from 'ktretrofit';
import { UserService } from './UserService';

// 创建Retrofit实例
const retrofit = createRetrofit('https://api.example.com')
  .addHeader('Content-Type', 'application/json')
  .setConnectTimeout(30000)
  .setReadTimeout(60000);

// 创建API服务实例
const userService = retrofit.create(UserService);

// 调用API方法
async function getUserList() {
  try {
    const users = await userService.getUsers(1, 10);
    console.log('Users:', users);
  } catch (error) {
    console.error('Error fetching users:', error);
  }
}

// 执行请求
getUserList();
```

## 支持的装饰器

### HTTP方法装饰器
- `@GET` - GET请求
- `@POST` - POST请求
- `@PUT` - PUT请求
- `@DELETE` - DELETE请求
- `@PATCH` - PATCH请求
- `@HEAD` - HEAD请求
- `@OPTIONS` - OPTIONS请求

### 参数装饰器
- `@Path` - 路径参数
- `@Query` - 查询参数
- `@QueryMap` - 多个查询参数
- `@Body` - 请求体
- `@Header` - 请求头
- `@HeaderMap` - 多个请求头
- `@Field` - 表单字段
- `@FieldMap` - 多个表单字段
- `@Part` - 多部分请求部分
- `@PartMap` - 多个多部分请求部分
- `@Url` - 动态URL
- `@Cookie` - Cookie

### 方法装饰器
- `@FormUrlEncoded` - 表单编码请求
- `@Multipart` - 多部分请求

## 构建配置

KTRetrofit使用以下系统API：
- @ohos.net.http (1.0.0)
- @ohos.util (1.0.0)
- @ohos.file.fs (1.0.0)
- @ohos.app.ability.common (1.0.0)

## 贡献

欢迎提交问题和Pull Request来帮助改进这个库。

## 许可证

KTRetrofit使用Apache License 2.0开源许可证。