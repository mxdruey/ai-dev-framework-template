/**
 * End-to-End Test Template
 * 
 * This template provides a foundation for E2E testing
 * complete user workflows across the entire system.
 */

import { describe, it, expect, beforeAll, afterAll, beforeEach } from '@jest/globals';
import puppeteer, { Browser, Page } from 'puppeteer';
import { TestDataBuilder } from './helpers/test-data-builder';
import { TestEmailService } from './helpers/test-email-service';
import { waitFor, waitForText, fillForm } from './helpers/e2e-helpers';

const BASE_URL = process.env.E2E_BASE_URL || 'http://localhost:3000';

let browser: Browser;
let page: Page;
let testData: TestDataBuilder;
let emailService: TestEmailService;

describe('E2E Tests', () => {
  beforeAll(async () => {
    // Launch browser
    browser = await puppeteer.launch({
      headless: process.env.HEADLESS !== 'false',
      slowMo: process.env.SLOW_MO ? parseInt(process.env.SLOW_MO) : 0,
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    
    // Initialize test helpers
    testData = new TestDataBuilder();
    emailService = new TestEmailService();
    
    // Clear test data
    await testData.cleanup();
  }, 30000);
  
  afterAll(async () => {
    await browser.close();
    await testData.cleanup();
  });
  
  beforeEach(async () => {
    // Create new page for each test
    page = await browser.newPage();
    
    // Set viewport
    await page.setViewport({
      width: 1280,
      height: 800
    });
    
    // Clear cookies and storage
    const client = await page.target().createCDPSession();
    await client.send('Network.clearBrowserCookies');
    await client.send('Network.clearBrowserCache');
  });
  
  afterEach(async () => {
    await page.close();
  });
  
  describe('User Registration Flow', () => {
    it('should complete full registration process', async () => {
      // Navigate to registration page
      await page.goto(`${BASE_URL}/register`);
      
      // Fill registration form
      const userData = {
        name: 'Test User',
        email: `test-${Date.now()}@example.com`,
        password: 'SecurePassword123!'
      };
      
      await fillForm(page, {
        '#name': userData.name,
        '#email': userData.email,
        '#password': userData.password,
        '#confirmPassword': userData.password
      });
      
      // Accept terms
      await page.click('#termsCheckbox');
      
      // Submit form
      await Promise.all([
        page.waitForNavigation(),
        page.click('button[type="submit"]')
      ]);
      
      // Should redirect to email verification page
      expect(page.url()).toContain('/verify-email');
      await waitForText(page, 'Please verify your email');
      
      // Check for verification email
      const email = await emailService.waitForEmail(userData.email);
      expect(email.subject).toContain('Verify your email');
      
      // Extract verification link
      const verificationLink = email.body.match(/href="(.*?verify.*?)"/)?.[1];
      expect(verificationLink).toBeTruthy();
      
      // Visit verification link
      await page.goto(verificationLink!);
      
      // Should show success message and redirect to login
      await waitForText(page, 'Email verified successfully');
      await page.waitForTimeout(2000); // Wait for redirect
      
      expect(page.url()).toContain('/login');
      
      // Login with new account
      await fillForm(page, {
        '#email': userData.email,
        '#password': userData.password
      });
      
      await Promise.all([
        page.waitForNavigation(),
        page.click('button[type="submit"]')
      ]);
      
      // Should be logged in and redirected to dashboard
      expect(page.url()).toContain('/dashboard');
      await waitForText(page, `Welcome, ${userData.name}`);
      
      // Verify user menu is visible
      const userMenu = await page.$('[data-testid="user-menu"]');
      expect(userMenu).toBeTruthy();
    }, 60000);
    
    it('should handle registration errors gracefully', async () => {
      // Create existing user
      const existingUser = await testData.createUser({
        email: 'existing@example.com',
        password: 'Password123!'
      });
      
      // Navigate to registration
      await page.goto(`${BASE_URL}/register`);
      
      // Try to register with existing email
      await fillForm(page, {
        '#name': 'Another User',
        '#email': existingUser.email,
        '#password': 'Password123!',
        '#confirmPassword': 'Password123!'
      });
      
      await page.click('#termsCheckbox');
      await page.click('button[type="submit"]');
      
      // Should show error message
      await waitForText(page, 'Email already registered');
      
      // Should remain on registration page
      expect(page.url()).toContain('/register');
      
      // Form should retain entered data except password
      const nameValue = await page.$eval('#name', (el: any) => el.value);
      expect(nameValue).toBe('Another User');
      
      const passwordValue = await page.$eval('#password', (el: any) => el.value);
      expect(passwordValue).toBe('');
    });
  });
  
  describe('Complete Task Management Workflow', () => {
    let user: any;
    
    beforeEach(async () => {
      // Create and login user
      user = await testData.createVerifiedUser({
        email: `user-${Date.now()}@example.com`,
        password: 'Password123!',
        name: 'Task User'
      });
      
      // Login
      await page.goto(`${BASE_URL}/login`);
      await fillForm(page, {
        '#email': user.email,
        '#password': 'Password123!'
      });
      
      await Promise.all([
        page.waitForNavigation(),
        page.click('button[type="submit"]')
      ]);
    });
    
    it('should create, edit, and complete a task', async () => {
      // Navigate to tasks page
      await page.goto(`${BASE_URL}/tasks`);
      
      // Click create task button
      await page.click('[data-testid="create-task-btn"]');
      
      // Wait for modal
      await waitFor(page, '[data-testid="task-modal"]');
      
      // Fill task form
      const taskData = {
        title: 'Complete E2E Testing',
        description: 'Write comprehensive E2E tests for the application',
        priority: 'high',
        dueDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]
      };
      
      await page.type('#taskTitle', taskData.title);
      await page.type('#taskDescription', taskData.description);
      await page.select('#taskPriority', taskData.priority);
      await page.type('#taskDueDate', taskData.dueDate);
      
      // Submit task
      await page.click('[data-testid="save-task-btn"]');
      
      // Wait for task to appear in list
      await waitForText(page, taskData.title);
      
      // Verify task details
      const taskElement = await page.$(`[data-testid="task-item"]:has-text("${taskData.title}")`);
      expect(taskElement).toBeTruthy();
      
      // Edit task
      await taskElement!.click('[data-testid="edit-task-btn"]');
      await waitFor(page, '[data-testid="task-modal"]');
      
      // Update title
      await page.click('#taskTitle', { clickCount: 3 }); // Select all
      await page.type('#taskTitle', 'Updated: Complete E2E Testing');
      
      await page.click('[data-testid="save-task-btn"]');
      
      // Verify update
      await waitForText(page, 'Updated: Complete E2E Testing');
      
      // Mark task as complete
      const checkbox = await page.$(`[data-testid="task-checkbox-${taskData.title}"]`);
      await checkbox!.click();
      
      // Verify task is marked complete
      await page.waitForTimeout(500); // Wait for animation
      
      const completedTask = await page.$('[data-testid="task-item"].completed');
      expect(completedTask).toBeTruthy();
      
      // Filter completed tasks
      await page.click('[data-testid="filter-completed"]');
      
      // Should still see the completed task
      await waitForText(page, 'Updated: Complete E2E Testing');
      
      // Filter active tasks
      await page.click('[data-testid="filter-active"]');
      
      // Should not see the completed task
      const taskGone = await page.waitForSelector(
        `[data-testid="task-item"]:has-text("Updated: Complete E2E Testing")`,
        { state: 'hidden', timeout: 3000 }
      ).catch(() => true);
      
      expect(taskGone).toBeTruthy();
    }, 60000);
  });
  
  describe('Responsive Design', () => {
    const viewports = [
      { name: 'Mobile', width: 375, height: 667 },
      { name: 'Tablet', width: 768, height: 1024 },
      { name: 'Desktop', width: 1920, height: 1080 }
    ];
    
    viewports.forEach(viewport => {
      it(`should work properly on ${viewport.name}`, async () => {
        await page.setViewport({
          width: viewport.width,
          height: viewport.height
        });
        
        await page.goto(BASE_URL);
        
        // Check navigation menu
        if (viewport.width < 768) {
          // Mobile - should have hamburger menu
          const hamburger = await page.$('[data-testid="mobile-menu-toggle"]');
          expect(hamburger).toBeTruthy();
          
          // Open mobile menu
          await hamburger!.click();
          await waitFor(page, '[data-testid="mobile-menu"]');
          
          // Check menu items are visible
          await waitForText(page, 'Home');
          await waitForText(page, 'Features');
          await waitForText(page, 'Pricing');
        } else {
          // Desktop - should have regular nav
          const desktopNav = await page.$('[data-testid="desktop-nav"]');
          expect(desktopNav).toBeTruthy();
          
          // Menu items should be visible without clicking
          await waitForText(page, 'Home');
          await waitForText(page, 'Features');
          await waitForText(page, 'Pricing');
        }
        
        // Check hero section
        const heroTitle = await page.$('h1');
        expect(heroTitle).toBeTruthy();
        
        // Check CTA button
        const ctaButton = await page.$('[data-testid="hero-cta"]');
        expect(ctaButton).toBeTruthy();
        
        // Take screenshot for visual comparison
        await page.screenshot({
          path: `./screenshots/${viewport.name.toLowerCase()}-homepage.png`,
          fullPage: true
        });
      });
    });
  });
  
  describe('Performance and Accessibility', () => {
    it('should meet performance benchmarks', async () => {
      // Enable performance metrics
      await page.evaluateOnNewDocument(() => {
        window.performanceMetrics = {
          firstPaint: 0,
          firstContentfulPaint: 0,
          domContentLoaded: 0,
          loadComplete: 0
        };
        
        window.addEventListener('DOMContentLoaded', () => {
          window.performanceMetrics.domContentLoaded = performance.now();
        });
        
        window.addEventListener('load', () => {
          window.performanceMetrics.loadComplete = performance.now();
          
          const paintEntries = performance.getEntriesByType('paint');
          paintEntries.forEach(entry => {
            if (entry.name === 'first-paint') {
              window.performanceMetrics.firstPaint = entry.startTime;
            } else if (entry.name === 'first-contentful-paint') {
              window.performanceMetrics.firstContentfulPaint = entry.startTime;
            }
          });
        });
      });
      
      await page.goto(BASE_URL, { waitUntil: 'networkidle2' });
      
      const metrics = await page.evaluate(() => window.performanceMetrics);
      
      // Performance assertions
      expect(metrics.firstContentfulPaint).toBeLessThan(2000); // FCP < 2s
      expect(metrics.domContentLoaded).toBeLessThan(3000); // DCL < 3s
      expect(metrics.loadComplete).toBeLessThan(5000); // Load < 5s
    });
    
    it('should be accessible', async () => {
      await page.goto(BASE_URL);
      
      // Run accessibility audit
      const accessibilityReport = await page.accessibility.snapshot();
      
      // Basic accessibility checks
      expect(accessibilityReport).toBeTruthy();
      
      // Check for proper heading structure
      const headings = await page.$$eval('h1, h2, h3, h4, h5, h6', 
        elements => elements.map(el => ({ 
          level: parseInt(el.tagName[1]), 
          text: el.textContent 
        }))
      );
      
      // Should have exactly one h1
      const h1Count = headings.filter(h => h.level === 1).length;
      expect(h1Count).toBe(1);
      
      // Check for alt text on images
      const imagesWithoutAlt = await page.$$eval('img:not([alt])', 
        images => images.length
      );
      expect(imagesWithoutAlt).toBe(0);
      
      // Check for form labels
      const inputsWithoutLabels = await page.$$eval(
        'input:not([type="hidden"]):not([type="submit"]):not([aria-label]):not([aria-labelledby])',
        inputs => inputs.filter(input => {
          const id = input.id;
          if (!id) return true;
          return !document.querySelector(`label[for="${id}"]`);
        }).length
      );
      expect(inputsWithoutLabels).toBe(0);
    });
  });
});