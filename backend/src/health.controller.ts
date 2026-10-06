import { Controller, Get } from '@nestjs/common';

@Controller('health')
export class HealthController {
  @Get()
  getHealth(): { status: 'ok'; service: 'pesoflow-api' } {
    return { status: 'ok', service: 'pesoflow-api' };
  }
}
