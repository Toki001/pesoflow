import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import { after, before, describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { AppModule } from '../src/app.module';
import { configureApp } from '../src/configure-app';

describe('API foundation', () => {
  let app: INestApplication;

  before(async () => {
    const module = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();
    app = module.createNestApplication();
    configureApp(app);
    await app.init();
  });

  after(async () => {
    await app.close();
  });

  it('serves only the versioned health endpoint with security headers', async () => {
    const response = await request(app.getHttpServer())
      .get('/v1/health')
      .expect(200);
    assert.deepEqual(response.body, { status: 'ok', service: 'pesoflow-api' });
    assert.equal(response.headers['x-content-type-options'], 'nosniff');
    await request(app.getHttpServer()).get('/health').expect(404);
    await request(app.getHttpServer()).get('/v1/accounts').expect(404);
  });
});
