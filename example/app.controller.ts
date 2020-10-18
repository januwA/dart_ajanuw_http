import {
  Controller,
  Get,
  Query,
  Body,
  Post,
  UseInterceptors,
  UploadedFile,
  NotFoundException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';

@Controller()
export class AppController {
  @Get('/api')
  get(@Query() query) {
    return query;
  }

  @Post('/api')
  post(@Body() body) {
    return body;
  }

  @Get('/api/retry')
  retry() {
    let t = Math.random();
    console.log(t);
    if (t > 0.5) return 'hello world';
    throw new NotFoundException();
  }

  @Post('/api/upload')
  @UseInterceptors(FileInterceptor('file'))
  upload(@UploadedFile() file, @Body() body) {
    console.log(file, body);
    return 'upload';
  }
}
