#import <Foundation/Foundation.h>

/**
 封装 rime_api.h 结构 rime_traits_t
 
 Should be initialized by calling RIME_STRUCT_INIT(Type, var)
 */
typedef struct RimeTraits {

  const char *sharedDataDir;
  const char *userDataDir;
  const char *distributionName;
  const char *distributionCodeName;
  const char *distributionVersion;

  // 传递一个格式为 "rime.x
  // "的C-string常量，其中'x'是你的应用程序的名称。添加前缀 "rime.
  // "以确保旧的日志文件被自动清理。
  const char *appName;
  // 初始化(initializing)前要加载的模块列表
  const char **modules;
  // v1.6
  /*! Minimal level of logged messages.
   *  Value is passed to Glog library using FLAGS_minloglevel variable.
   *  0 = INFO (default), 1 = WARNING, 2 = ERROR, 3 = FATAL
   */
  // 记录日志的最小级别。这个值是通过FLAGS_minloglevel变量传递给Glog库的。0 =
  // INFO（默认），1 = WARNING，2 = ERROR，3 = FATAL。
  int minLogLevel;
  // 日志文件的目录。该值使用FLAGS_log_dir变量传递给Glog库。
  const char *logDir;
  // 预先构建的数据目录中。默认为${shared_data_dir}/build
  const char *prebuiltDataDir;
  // 暂存目录，默认为${user_data_dir}/build
  const char *stagingDir;

}

typedef struct RimeStatus {

  const char *schemaId;
  const char *schemaName;
  bool isASCIIMode;
  bool isASCIIPunct;
  bool isComposing;
  bool isDisabled;
  bool isFullShape;
  bool isSimplified;
  bool isTraditional;

}

typedef struct RimeCandidate {

  const char *text;
  const char *comment;

}

typedef struct RimeMenu {

  int pageSize;
  int pageNo;
  bool isLastPage;
  int highlightedCandidateIndex;
  int numCandidates;
  const char *selectKeys;
  RimeCandidate **candidates;

}

typedef struct RimeComposition {

  int length, cursorPos, selStart, selEnd;
  const char *preedit;

}

typedef struct RimeContext {

  const char *commitTextPreview;
  IRimeMenu *menu;
  IRimeComposition *composition;
  const char **labels;

}

typedef struct IRimeConfigIteratorItem {

  int index;
  const char *key;
  const char *path;
  void *list;
  void *map;

}


@interface IRimeConfig : NSObject

- (NSString *)getString:(NSString *)key;
- (NSNumber *)getBool:(NSString *)key;
- (NSNumber *)getInt:(NSString *)key;
- (BOOL)setInt:(int) value forOption(NSString *)key;
- (NSNumber *)getDouble:(NSString *)key;

- (NSArray<IRimeConfigIteratorItem *> *)getItems:(NSString *)key;
- (NSArray<IRimeConfigIteratorItem *> *)getMapValues:(NSString *)key;
- (void) closeConfig;

@end


