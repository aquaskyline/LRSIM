#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <sys/stat.h>
#include <unistd.h>
#include <vector>
#include <string>

using namespace std;

static inline vector<string> SplitString(const char *, char = '\t');
static inline bool FileExistsTest (const char *);
static string GetPath (const string&);

int main(int argc, char **argv)
{
  //Check parameters
  if(argc < 4)
  {
    fprintf(stderr, "Usage: %s [Manifest input] [Reads input] [Output Prefix]\n", argv[0]);
    exit(EXIT_FAILURE);
  }
  if(!FileExistsTest(argv[1])) {fprintf(stderr, "%s not exist, program terminated\n", argv[1]);exit(EXIT_FAILURE);}
  if(!FileExistsTest(argv[2])) {fprintf(stderr, "%s not exist, program terminated\n", argv[2]);exit(EXIT_FAILURE);}
  if(argv[3][strlen(argv[3])-1] == '/' ) {fprintf(stderr, "Output prefix cannot end with /, program terminated\n");exit(EXIT_FAILURE);}
  char bfrPath[1024], pigzPath[1024];
  int fastOutputModule = 0;
  strcpy(bfrPath, (GetPath(argv[0]) + string("bfr")).c_str());
  strcpy(pigzPath, (GetPath(argv[0]) + string("pigz")).c_str());
  if(FileExistsTest(bfrPath)) { ++fastOutputModule; }
  if(FileExistsTest(pigzPath)) { ++fastOutputModule; }
  
  //Open input files
  FILE *manifestIFH, *readsIFH;
  {
    manifestIFH = fopen(argv[1], "r");
    if(manifestIFH == NULL) {fprintf(stderr, "Error opening %s, program terminated\n", argv[1]);exit(EXIT_FAILURE);}
    readsIFH = fopen(argv[2], "r");
    if(readsIFH == NULL) {fprintf(stderr, "Error opening %s, program terminated\n", argv[2]);exit(EXIT_FAILURE);}
  }
  
  //Open output files
  FILE *fq1OFH, *fq2OFH;
  {
    char cmd1[1024];
    char cmd2[1024];
    if(fastOutputModule == 2)
    {
      sprintf(cmd1, "%s | %s -p 12 -c > %s_R1_001.fastq.gz", bfrPath, pigzPath, argv[3]);
      sprintf(cmd2, "%s | %s -p 12 -c > %s_R2_001.fastq.gz", bfrPath, pigzPath, argv[3]);
    }
    else
    {
      sprintf(cmd1, "gzip -c > %s_R1_001.fastq.gz", argv[3]);
      sprintf(cmd2, "gzip -c > %s_R2_001.fastq.gz", argv[3]);
    }
    fq1OFH = popen(cmd1, "w");
    fq2OFH = popen(cmd2, "w");
    if(fq1OFH == NULL) {fprintf(stderr, "Error opening %s_R1_001.fastq.gz, program terminated\n", argv[3]);exit(EXIT_FAILURE);}
    if(fq2OFH == NULL) {fprintf(stderr, "Error opening %s_R2_001.fastq.gz, program terminated\n", argv[3]);exit(EXIT_FAILURE);}
  }
  
  //Output
  size_t count = 0;
  while(!feof(manifestIFH))
  {
    size_t filePosition; char bcSeq[1024]; char bcQual[1024];
    {
      char buf[1024];
      int len;
      if((fgets(buf, 1023, manifestIFH)) != NULL)
      {
        len = strlen(buf);
        if(len == 0) {fprintf(stderr, "Read empty row from manifest file, program terminated\n");exit(EXIT_FAILURE);}
        buf[ strlen(buf) - 1 ] = '\0';
      } else { continue; }
      vector<string> ary = SplitString(buf);
      if(ary.size() != 3) {fprintf(stderr, "%s, manifest file columns != 3, program terminated\n", buf);exit(EXIT_FAILURE);}
      filePosition = strtoul(ary[0].c_str(), NULL, 0);
      strcpy(bcSeq, ary[1].c_str());
      strcpy(bcQual, ary[2].c_str());
    }
    
    //Go to the position
    size_t readsIFHPtr = ftell(readsIFH);
    if(readsIFHPtr > filePosition)
    { fprintf(stderr, "manifestIFHPtr > filePosition\n");exit(EXIT_FAILURE); }
    while(readsIFHPtr < filePosition)
    {
      getc(readsIFH);
      ++readsIFHPtr;
    }
    
    char buf1[1024], buf2[1024], buf3[1024], buf4[1024], buf5[1024], buf6[1024], buf7[1024], buf8[1024];
    //Get the read
    {
      if((fgets(buf1, 1023, readsIFH)) == NULL) {fprintf(stderr, "readsIFH error, program terminated\n");exit(EXIT_FAILURE);}
      if((fgets(buf2, 1023, readsIFH)) == NULL) {fprintf(stderr, "readsIFH error, program terminated\n");exit(EXIT_FAILURE);}
      if((fgets(buf3, 1023, readsIFH)) == NULL) {fprintf(stderr, "readsIFH error, program terminated\n");exit(EXIT_FAILURE);}
      if((fgets(buf4, 1023, readsIFH)) == NULL) {fprintf(stderr, "readsIFH error, program terminated\n");exit(EXIT_FAILURE);}
      if((fgets(buf5, 1023, readsIFH)) == NULL) {fprintf(stderr, "readsIFH error, program terminated\n");exit(EXIT_FAILURE);}
      if((fgets(buf6, 1023, readsIFH)) == NULL) {fprintf(stderr, "readsIFH error, program terminated\n");exit(EXIT_FAILURE);}
      if((fgets(buf7, 1023, readsIFH)) == NULL) {fprintf(stderr, "readsIFH error, program terminated\n");exit(EXIT_FAILURE);}
      if((fgets(buf8, 1023, readsIFH)) == NULL) {fprintf(stderr, "readsIFH error, program terminated\n");exit(EXIT_FAILURE);}
    }
    
    //Output
    {
      buf1[strcspn(buf1, "\r\n")] = 0;
      fprintf(fq1OFH, "%s 1:N:0:1\n%s%s%s%s%s", buf1, bcSeq, buf2, buf3, bcQual, buf4);
      buf5[strcspn(buf5, "\r\n")] = 0;
      fprintf(fq2OFH, "%s 2:N:0:1\n%s%s%s", buf5, buf6, buf7, buf8);
      ++count;
      if(count % 100000 == 0)
      {
        fprintf(stderr, "%lu reads extracted already.\n", count);
      }
    }
  }
  
  fclose(manifestIFH);
  fclose(readsIFH);
  pclose(fq1OFH);
  pclose(fq2OFH);
  
  return EXIT_SUCCESS;
}

static inline vector<string> SplitString(const char *str, char c)
{
  vector<string> result;

  do
  {
    const char *begin = str;

    while(*str != c && *str)
      str++;

    result.push_back(string(begin, str));
  } while (0 != *str++);

  return result;
}

static inline bool FileExistsTest (const char *name)
{
  struct stat buffer;
  return (stat (name, &buffer) == 0);
}

static string GetPath (const string& str)
{
  int found;
  found=str.find_last_of("/\\");
  if(found == -1)
  {
    return string("./");
  }
  else
  {
    return str.substr(0,found) + string("/");
  }
}

