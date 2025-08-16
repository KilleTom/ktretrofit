import { GET, POST, DELETE, PUT, Path, Query, Body, Header, FormUrlEncoded, Field, QueryMap, HeaderMap, Url, Cookie, Multipart, Part } from '../../retrofit';

/**
 * User model
 */
export interface User {
  id: number;
  name: string;
  email: string;
  createdAt: string;
}

/**
 * User creation request
 */
export interface CreateUserRequest {
  name: string;
  email: string;
  password: string;
}

/**
 * User API service
 */
export class UserService {
  @GET('/users')
  getUsers(@Query('page') page: number, @Query('limit') limit: number): Promise<User[]> {}

  @GET('/users/{id}')
  getUserById(@Path('id') id: number): Promise<User> {}

  @POST('/users')
  createUser(@Body() user: CreateUserRequest): Promise<User> {}

  @PUT('/users/{id}')
  updateUser(@Path('id') id: number, @Body() user: Partial<User>): Promise<User> {}

  @DELETE('/users/{id}')
  deleteUser(@Path('id') id: number): Promise<void> {}

  @GET('/users/profile')
  getUserProfile(@Header('Authorization') token: string): Promise<User> {}

  /**
   * Login user with form data
   */
  @FormUrlEncoded
  @POST('/auth/login')
  loginUser(@Field('email') email: string, @Field('password') password: string): Promise<{ token: string; user: User }> {}

  /**
   * Search users with multiple query parameters
   */
  @GET('/users/search')
  searchUsers(@QueryMap() queryParams: Record<string, any>): Promise<User[]> {}

  /**
   * Update user settings with custom headers
   */
  @POST('/users/settings')
  updateUserSettings(@Body() settings: any, @HeaderMap() customHeaders: Record<string, string>): Promise<any> {}

  /**
   * Request with dynamic URL
   */
  @GET('')
  requestWithDynamicUrl(@Url() url: string): Promise<any> {}

  /**
   * Request with cookie
   */
  @GET('/users/sessions')
  getUserSessions(@Cookie('sessionId') sessionId: string): Promise<any> {}

  /**
   * Upload user avatar (multipart)
   */
  @Multipart
  @POST('/users/avatar')
  uploadAvatar(@Part('avatar') avatar: any, @Part('userId') userId: number): Promise<any> {}
}