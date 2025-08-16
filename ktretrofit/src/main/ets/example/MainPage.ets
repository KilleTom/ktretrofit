import { createRetrofit } from '../../retrofit/Index';
import { UserService, User, CreateUserRequest } from './UserService';
import { Button, Column, Row, Text, ScrollView, Progress } from '@ohos.arkui';
import Toast from '@ohos.toast';

@Entry
@Component
struct MainPage {
  @State users: User[] = [];
  @State currentUser: User | null = null;
  @State loading: boolean = false;
  @State message: string = '';
  private userService: UserService;

  constructor() {
    // Create Retrofit instance
    const retrofit = createRetrofit('https://jsonplaceholder.typicode.com')
      .addHeader('Content-Type', 'application/json');

    // Create API service instance
    this.userService = retrofit.create(UserService);
  }

  // Get user list
  async getUsers() {
    this.loading = true;
    try {
      this.users = await this.userService.getUsers(1, 10);
      this.message = `Loaded ${this.users.length} users`;
    } catch (error) {
      this.message = `Error: ${error.message}`;
      Toast.show({ message: this.message, duration: 3000 });
    } finally {
      this.loading = false;
    }
  }

  // Get user by ID
  async getUserById() {
    this.loading = true;
    try {
      this.currentUser = await this.userService.getUserById(1);
      this.message = `Loaded user: ${this.currentUser?.name}`;
    } catch (error) {
      this.message = `Error: ${error.message}`;
      Toast.show({ message: this.message, duration: 3000 });
    } finally {
      this.loading = false;
    }
  }

  // Create user
  async createUser() {
    this.loading = true;
    try {
      const newUser: CreateUserRequest = {
        name: 'John Doe',
        email: 'john@example.com',
        password: 'password123'
      };
      const createdUser = await this.userService.createUser(newUser);
      this.message = `Created user with ID: ${createdUser.id}`;
      this.currentUser = createdUser;
    } catch (error) {
      this.message = `Error: ${error.message}`;
      Toast.show({ message: this.message, duration: 3000 });
    } finally {
      this.loading = false;
    }
  }

  // Update user
  async updateUser() {
    if (!this.currentUser) {
      this.message = 'Please load a user first';
      Toast.show({ message: this.message, duration: 3000 });
      return;
    }

    this.loading = true;
    try {
      const updatedUser = await this.userService.updateUser(this.currentUser.id, {
        name: 'Updated Name'
      });
      this.message = `Updated user: ${updatedUser.name}`;
      this.currentUser = updatedUser;
    } catch (error) {
      this.message = `Error: ${error.message}`;
      Toast.show({ message: this.message, duration: 3000 });
    } finally {
      this.loading = false;
    }
  }

  // Delete user
  async deleteUser() {
    if (!this.currentUser) {
      this.message = 'Please load a user first';
      Toast.show({ message: this.message, duration: 3000 });
      return;
    }

    this.loading = true;
    try {
      await this.userService.deleteUser(this.currentUser.id);
      this.message = `Deleted user with ID: ${this.currentUser.id}`;
      this.currentUser = null;
    } catch (error) {
      this.message = `Error: ${error.message}`;
      Toast.show({ message: this.message, duration: 3000 });
    } finally {
      this.loading = false;
    }
  }

  // Login user (using FormUrlEncoded and Field)
  async loginUser() {
    this.loading = true;
    try {
      const result = await this.userService.loginUser('john@example.com', 'password123');
      this.message = `Login successful, token: ${result.token.substring(0, 10)}...`;
      if (result.user) {
        this.currentUser = result.user;
      }
    } catch (error) {
      this.message = `Login error: ${error.message}`;
      Toast.show({ message: this.message, duration: 3000 });
    } finally {
      this.loading = false;
    }
  }

  // Search users (using QueryMap)
  async searchUsers() {
    this.loading = true;
    try {
      const queryParams = {
        name: 'John',
        status: 'active',
        page: 1,
        limit: 5
      };
      this.users = await this.userService.searchUsers(queryParams);
      this.message = `Found ${this.users.length} users matching search criteria`;
    } catch (error) {
      this.message = `Search error: ${error.message}`;
      Toast.show({ message: this.message, duration: 3000 });
    } finally {
      this.loading = false;
    }
  }

  // Update user settings (using HeaderMap)
  async updateUserSettings() {
    this.loading = true;
    try {
      const settings = {
        notifications: true,
        theme: 'dark'
      };
      const customHeaders = {
        'X-API-Key': 'api-key-123',
        'X-Client-Version': '1.0.0'
      };
      await this.userService.updateUserSettings(settings, customHeaders);
      this.message = 'User settings updated successfully';
    } catch (error) {
      this.message = `Settings update error: ${error.message}`;
      Toast.show({ message: this.message, duration: 3000 });
    } finally {
      this.loading = false;
    }
  }

  // Request with dynamic URL (using Url)
  async requestWithDynamicUrl() {
    this.loading = true;
    try {
      const dynamicUrl = 'https://jsonplaceholder.typicode.com/posts/1';
      const result = await this.userService.requestWithDynamicUrl(dynamicUrl);
      this.message = `Dynamic URL request successful, title: ${result.title}`;
    } catch (error) {
      this.message = `Dynamic URL error: ${error.message}`;
      Toast.show({ message: this.message, duration: 3000 });
    } finally {
      this.loading = false;
    }
  }

  // Request with cookie (using Cookie)
  async requestWithCookie() {
    this.loading = true;
    try {
      const sessionId = 'session-12345';
      await this.userService.getUserSessions(sessionId);
      this.message = 'Cookie request successful';
    } catch (error) {
      this.message = `Cookie request error: ${error.message}`;
      Toast.show({ message: this.message, duration: 3000 });
    } finally {
      this.loading = false;
    }
  }

  // Upload avatar (using Multipart and Part)
  async uploadAvatar() {
    this.loading = true;
    try {
      // In a real app, this would be an actual file
      const avatar = { name: 'avatar.jpg', type: 'image/jpeg' };
      const userId = this.currentUser?.id || 1;
      await this.userService.uploadAvatar(avatar, userId);
      this.message = 'Avatar uploaded successfully';
    } catch (error) {
      this.message = `Upload error: ${error.message}`;
      Toast.show({ message: this.message, duration: 3000 });
    } finally {
      this.loading = false;
    }
  }

  build() {
    Column() {
      Text('KTRetrofit Example')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin(20);

      Text(this.message)
        .margin(10);

      if (this.loading) {
        Progress()
          .type(ProgressType.Linear)
          .width('80%')
          .height(10)
          .margin(10);
      }

      Row() {
        Button('Get Users')
          .onClick(() => this.getUsers())
          .margin(5);

        Button('Get User by ID')
          .onClick(() => this.getUserById())
          .margin(5);
      }

      Row() {
        Button('Create User')
          .onClick(() => this.createUser())
          .margin(5);

        Button('Update User')
          .onClick(() => this.updateUser())
          .margin(5);
      }

      Row() {
        Button('Delete User')
          .onClick(() => this.deleteUser())
          .margin(5);
        Button('Login User')
          .onClick(() => this.loginUser())
          .margin(5);
      }

      Row() {
        Button('Search Users')
          .onClick(() => this.searchUsers())
          .margin(5);
        Button('Update Settings')
          .onClick(() => this.updateUserSettings())
          .margin(5);
      }

      Row() {
        Button('Dynamic URL')
          .onClick(() => this.requestWithDynamicUrl())
          .margin(5);
        Button('With Cookie')
          .onClick(() => this.requestWithCookie())
          .margin(5);
      }

      Row() {
        Button('Upload Avatar')
          .onClick(() => this.uploadAvatar())
          .margin(5);
      }

      ScrollView() {
        Column() {
          if (this.currentUser) {
            Text(`Current User: ${this.currentUser.name}`)
              .fontSize(18)
              .margin(10);
            Text(`ID: ${this.currentUser.id}`)
              .margin(5);
            Text(`Email: ${this.currentUser.email}`)
              .margin(5);
          }

          if (this.users.length > 0) {
            Text('User List:')
              .fontSize(18)
              .margin(10);
            ForEach(this.users, (user) => {
              Column() {
                Text(`Name: ${user.name}`)
                Text(`ID: ${user.id}`)
                Text(`Email: ${user.email}`)
              }
              .borderWidth(1)
              .padding(10)
              .margin(5)
              .width('100%');
            });
          }
        }
      }
      .flexGrow(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding(20);
  }
}