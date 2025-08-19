import localUnitTest from './LocalUnit.test';
import retrofitPathTest from './RetrofitPathTest';

export default function testsuite() {
  localUnitTest();
  retrofitPathTest();
}