import {
  Controller,
  Get,
  Query,
  Body,
  Post,
  Headers,
  UseInterceptors,
  UploadedFile,
  NotFoundException,
} from "@nestjs/common";
import { FileInterceptor } from "@nestjs/platform-express";

@Controller("/api")
export class AppController {
  @Get()
  get(@Query() query, @Headers() headers) {
    console.log(query);
    console.log(headers);

    return query;
  }

  @Post()
  post(@Body() body) {
    console.log(body);
    return body;
  }

  @Get("/retry")
  retry() {
    let t = Math.random();
    console.log(t);
    if (t > 0.5) return "hello world";
    throw new NotFoundException();
  }

  @Post("/upload")
  @UseInterceptors(FileInterceptor("file"))
  upload(@UploadedFile() file, @Body() body) {
    console.log(file, body);
    return "upload";
  }
}
