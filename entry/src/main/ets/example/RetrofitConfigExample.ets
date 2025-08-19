/**
 * Example of using Retrofit with configuration objects (without annotations)
 * This approach is compatible with HarmonyOS which has limitations on annotation标记接口及抽象方法
 */

import { createRetrofit } from 'ktretrofit';
import { Call } from 'ktretrofit/src/main/ets/retrofit/call/Call';
import { ApiServiceConfig, ApiParameterConfig } from 'ktretrofit/src/main/ets/retrofit/config/ApiConfig';
import { HttpParameterType } from 'ktretrofit/src/main/ets/retrofit/http/param/HttpParameterType';
import { HttpMethod } from 'ktretrofit/src/main/ets/retrofit/http/method/HttpMethod';

// Define data models
interface User {
  id: number;
  name: string;
  email: string;
}

interface CreateUserRequest {
  name: string;
  email: string;
  password: string;
}

// Example of using Retrofit with configuration objects
class RetrofitConfigExample {
  private retrofit = createRetrofit('https://api.example.com')
    .addHeader('Content-Type', 'application/json')
    .setConnectTimeout(30000)
    .setReadTimeout(60000).build();

  // Define user service configuration (instead of using annotations)
  private userServiceConfig: ApiServiceConfig<UserService>;

  // Constructor to initialize the configuration
  constructor() {
    this.userServiceConfig = this.createUserServiceConfig();
  }

  // Create the user service configuration with proper type annotations
  private createUserServiceConfig(): ApiServiceConfig<UserService> {
    // Define path parameter configuration
    const pathIdParam: ApiParameterConfig = {
      type: HttpParameterType.PATH,
      name: 'id'
    };

    // Define query parameter configurations
    const queryPageParam: ApiParameterConfig = {
      type: HttpParameterType.QUERY,
      name: 'page'
    };

    const queryLimitParam: ApiParameterConfig = {
      type: HttpParameterType.QUERY,
      name: 'limit'
    };

    // Define body parameter configuration
    const bodyParam: ApiParameterConfig = {
      type: HttpParameterType.BODY
    };

    // Define field parameter configurations
    const fieldUsernameParam: ApiParameterConfig = {
      type: HttpParameterType.FIELD,
      name: 'username'
    };

    const fieldPasswordParam: ApiParameterConfig = {
      type: HttpParameterType.FIELD,
      name: 'password'
    };

    // Define header parameter configuration
    const headerAuthParam: ApiParameterConfig = {
      type: HttpParameterType.HEADER,
      name: 'Authorization'
    };

    // Define queryMap parameter configuration
    const queryMapParam: ApiParameterConfig = {
      type: HttpParameterType.QUERY_MAP
    };

    // Create the service configuration
    const config: ApiServiceConfig<UserService> = {
      // Set service name to match the interface name for better logging and error messages
      serviceName: 'UserService',
      methods: {
        // GET /users?page={page}&limit={limit}
        "getUsers": {
          method: HttpMethod.GET,
          path: '/users',
          parameters: {
            0: queryPageParam,  // First parameter is page number
            1: queryLimitParam  // Second parameter is limit
          }
        },

        // GET /users/{id}
        "getUserById": {
          method: HttpMethod.GET,
          path: '/users/{id}',
          parameters: {
            0: pathIdParam  // First parameter is path ID
          }
        },

        // POST /users
        "createUser": {
          method: HttpMethod.POST,
          path: '/users',
          parameters: {
            0: bodyParam  // First parameter is request body
          }
        },

        // PUT /users/{id}
        "updateUser": {
          method: HttpMethod.PUT,
          path: '/users/{id}',
          parameters: {
            0: pathIdParam,  // First parameter is path ID
            1: bodyParam     // Second parameter is request body
          }
        },

        // DELETE /users/{id}
        "deleteUser": {
          method: HttpMethod.DELETE,
          path: '/users/{id}',
          parameters: {
            0: pathIdParam  // First parameter is path ID
          }
        },

        // Example with form encoding
        "login": {
          method: HttpMethod.POST,
          path: '/login',
          isFormEncoded: true,
          parameters: {
            0: fieldUsernameParam,
            1: fieldPasswordParam
          }
        },

        // Example with header parameters
        "getWithAuth": {
          method: HttpMethod.GET,
          path: '/protected/resource',
          parameters: {
            0: headerAuthParam
          }
        },

        // Example with query map
        "searchUsers": {
          method: HttpMethod.GET,
          path: '/users/search',
          parameters: {
            0: queryMapParam  // First parameter is a map of query parameters
          }
        }
      }
    };

    return config;
  };

  // Create API service instance using the configuration
  private createUserService(): UserService {
    return this.retrofit.configService(this.userServiceConfig);
  }

  // Example methods to demonstrate usage
  // Get list of users with pagination
   getUsersExample(page: number = 1, limit: number = 10): User[] {
    try {
      const userService = this.createUserService();
      const call = userService.getUsers(page, limit);
      const response = call.execute();

      
      console.log('Users fetched successfully:', response.body);

      return response.getNotNullBody();
    } catch (error) {
      console.error('Failed to fetch users:', error);
      throw error instanceof Error ? error : new Error(String(error));
    }
  }

  // Get user by ID

   getUserByIdExample(id: number): User {
    try {
      const userService = this.createUserService();
      const call = userService.getUserById(id);
      const response = call.execute();

      console.log('User fetched successfully:', response.body);
      return response.getNotNullBody();
    } catch (error) {
      console.error('Failed to fetch user by ID:', error);
      throw error instanceof Error ? error : new Error(String(error));
    }
  }

  // Create a new user
   createUserExample(userData: CreateUserRequest): User {
    try {
      const userService = this.createUserService();
      const call = userService.createUser(userData);
      const response = call.execute();
      
      console.log('User created successfully:', response.body);
      return response.getNotNullBody();
    } catch (error) {
      console.error('Failed to create user:', error);
      throw error instanceof Error ? error : new Error(String(error));
    }
  }

  // Update existing user
   updateUserExample(id: number, userData: Partial<User>): User {
    try {
      const userService = this.createUserService();
      const call = userService.updateUser(id, userData);
      const response = call.execute();
      
      console.log('User updated successfully:', response.body);
      return response.getNotNullBody();
    } catch (error) {
      console.error('Failed to update user:', error);
      throw error instanceof Error ? error : new Error(String(error));
    }
  }

  // Delete user
   deleteUserExample(id: number): void {
    try {
      const userService = this.createUserService();
      const call = userService.deleteUser(id);
      call.execute();
      
      console.log('User deleted successfully');
    } catch (error) {
      console.error('Failed to delete user:', error);
      throw error instanceof Error ? error : new Error(String(error));
    }
  }

  // User login example
   loginExample(username: string, password: string): LoginResponse {
    try {
      const userService = this.createUserService();
      const call = userService.login(username, password);
      const response = call.execute();
      
      console.log('Login successful:', response.body);
      return response.getNotNullBody();
    } catch (error) {
      console.error('Login failed:', error);
      throw error instanceof Error ? error : new Error(String(error));
    }
  }

  // Example with authentication header
   getProtectedResourceExample(authToken: string): ProtectedResource {
    try {
      const userService = this.createUserService();
      const call = userService.getWithAuth(authToken);
      const response = call.execute();
      
      console.log('Protected resource fetched successfully:', response.body);
      return response.getNotNullBody();
    } catch (error) {
      console.error('Failed to fetch protected resource:', error);
      throw error instanceof Error ? error : new Error(String(error));
    }
  }

  // Example with query map
   searchUsersExample(queryParams: Record<string, string>): User[] {
    try {
      const userService = this.createUserService();
      const call = userService.searchUsers(queryParams);
      const response = call.execute();
      
      console.log('Users search results:', response.body);
      return response.getNotNullBody();
    } catch (error) {
      console.error('User search failed:', error);
      throw error instanceof Error ? error : new Error(String(error));
    }

  }

  // Example using getNotNullBody() method for simplified error handling
  searchUsersWithNotNullBodyExample(queryParams: Record<string, string>): User[] {
    try {
      const userService = this.createUserService();
      const call = userService.searchUsers(queryParams);
      const response = call.execute();
      
      // Using getNotNullBody() to automatically check for successful response and non-null body
      // This will throw exceptions automatically if request failed or body is null
      const users = response.getNotNullBody();
      
      console.log('Users search results using getNotNullBody():', users);
      return users;
    } catch (error) {
      console.error('User search failed with getNotNullBody():', error);
      throw error instanceof Error ? error : new Error(String(error));
    }
  }

}

// Define additional response types to replace 'any'
interface LoginResponse {
  token: string;
  userId: number;
  expiresAt: number;
}

interface ProtectedResource {
  id: string;
  data: Record<string, object>;
  permissions: string[];
}

// Define the service interface (for type safety)
interface UserService {
  getUsers(page: number, limit: number): Call<User[]>;
  getUserById(id: number): Call<User>;
  createUser(user: CreateUserRequest): Call<User>;
  updateUser(id: number, user: Partial<User>): Call<User>;
  deleteUser(id: number): Call<void>;
  login(username: string, password: string): Call<LoginResponse>;
  getWithAuth(authToken: string): Call<ProtectedResource>;
  searchUsers(queryParams: Record<string, string>): Call<User[]>;
}

// Export the example class for use in other files
export default RetrofitConfigExample;