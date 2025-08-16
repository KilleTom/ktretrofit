// Export all from retrofit index
import * as retrofit from './src/main/ets/retrofit/Index';

// Export all as a single module
export const {
  GET,
  POST,
  PUT,
  DELETE,
  PATCH,
  HEAD,
  Query,
  QueryMap,
  QueryName,
  Body,
  Header,
  HeaderMap,
  Path,
  Field,
  FieldMap,
  Part,
  PartMap,
  Url,
  Cookie,
  Tag,
  FormUrlEncoded,
  Multipart,
  Retrofit,
  RetrofitBuilder,
  createRetrofit,
  HttpMethod,
  MetadataUtil
} = retrofit;

export default retrofit;