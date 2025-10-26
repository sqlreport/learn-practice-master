import apiClient from './api';
import { User, PaginatedResponse, CreateUserRequest, LoginRequest, AuthResponse } from '../types';

export const userService = {
  // Get all users with pagination
  async getUsers(page: number = 1, perPage: number = 10): Promise<PaginatedResponse<User>> {
    const response = await apiClient.get(`/users?page=${page}&per_page=${perPage}`);
    return response.data.data;
  },

  // Create new user
  async createUser(userData: CreateUserRequest): Promise<User> {
    const response = await apiClient.post('/users/', userData);
    return response.data.data;
  },

  // Get user by ID
  async getUserById(id: number): Promise<User> {
    const response = await apiClient.get(`/users/${id}`);
    return response.data.data;
  },

  // Update user
  async updateUser(id: number, userData: Partial<CreateUserRequest>): Promise<User> {
    const response = await apiClient.put(`/users/${id}`, userData);
    return response.data.data;
  },

  // Delete user
  async deleteUser(id: number): Promise<void> {
    await apiClient.delete(`/users/${id}`);
  },
};

export const authService = {
  // Login user
  async login(credentials: LoginRequest): Promise<AuthResponse> {
    const response = await apiClient.post('/auth/login', credentials);
    const { token, user } = response.data.data;
    localStorage.setItem('authToken', token);
    return { token, user };
  },

  // Register user
  async register(userData: CreateUserRequest): Promise<AuthResponse> {
    const response = await apiClient.post('/auth/register', userData);
    const { token, user } = response.data.data;
    localStorage.setItem('authToken', token);
    return { token, user };
  },

  // Logout user
  logout(): void {
    localStorage.removeItem('authToken');
  },

  // Check if user is authenticated
  isAuthenticated(): boolean {
    return !!localStorage.getItem('authToken');
  },
};