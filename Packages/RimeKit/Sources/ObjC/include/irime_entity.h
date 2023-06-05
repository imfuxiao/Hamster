#import <Foundation/Foundation.h>

/**
 封装 rime_api.h 结构 rime_traits_t
 
 Should be initialized by calling RIME_STRUCT_INIT(Type, var)
 */
@interface IRimeTraits : NSObject {
  NSString *sharedDataDir;
  NSString *userDataDir;
  NSString *distributionName;
  NSString *distributionCodeName;
  NSString *distributionVersion;
  
  // 传递一个格式为 "rime.x
  // "的C-string常量，其中'x'是你的应用程序的名称。添加前缀 "rime.
  // "以确保旧的日志文件被自动清理。
  NSString *appName;
  // 初始化(initializing)前要加载的模块列表
  NSArray<NSString *> *modules;
  // v1.6
  /*! Minimal level of logged messages.
   *  Value is passed to Glog library using FLAGS_minloglevel variable.
   *  0 = INFO (default), 1 = WARNING, 2 = ERROR, 3 = FATAL
   */
  // 记录日志的最小级别。这个值是通过FLAGS_minloglevel变量传递给Glog库的。0 =
  // INFO（默认），1 = WARNING，2 = ERROR，3 = FATAL。
  int minLogLevel;
  // 日志文件的目录。该值使用FLAGS_log_dir变量传递给Glog库。
  NSString *logDir;
  // 预先构建的数据目录中。默认为${shared_data_dir}/build
  NSString *prebuiltDataDir;
  // 暂存目录，默认为${user_data_dir}/build
  NSString *stagingDir;
}

@property NSString *sharedDataDir;
@property NSString *userDataDir;
@property NSString *distributionName;
@property NSString *distributionCodeName;
@property NSString *distributionVersion;
@property NSString *appName;
@property NSArray<NSString *> *modules;
@property int minLogLevel;
@property NSString *logDir;
@property NSString *prebuiltDataDir;
@property NSString *stagingDir;

@end

@interface IRimeSchema : NSObject {
  NSString *schemaId;
  NSString *schemaName;
}

@property NSString *schemaId;
@property NSString *schemaName;

- (id)initWithSchemaId:(NSString *)schemaId andSchemaName:(NSString *)name;

@end

@interface IRimeStatus : NSObject {
  NSString *schemaId;
  NSString *schemaName;
  BOOL isASCIIMode;
  BOOL isASCIIPunct;
  BOOL isComposing;
  BOOL isDisabled;
  BOOL isFullShape;
  BOOL isSimplified;
  BOOL isTraditional;
}

@property NSString *schemaId;
@property NSString *schemaName;
@property BOOL isASCIIMode;
@property BOOL isASCIIPunct;
@property BOOL isComposing;
@property BOOL isDisabled;
@property BOOL isFullShape;
@property BOOL isSimplified;
@property BOOL isTraditional;

@end

@interface IRimeCandidate : NSObject {
  NSString *text;
  NSString *comment;
}

@property NSString *text;
@property NSString *comment;

@end

@interface IRimeMenu : NSObject {
  int pageSize;
  int pageNo;
  BOOL isLastPage;
  int highlightedCandidateIndex;
  int numCandidates;
  NSString *selectKeys;
  NSArray<IRimeCandidate *> *candidates;
}

@property int pageSize;
@property int pageNo;
@property BOOL isLastPage;
@property int highlightedCandidateIndex;
@property int numCandidates;
@property NSString *selectKeys;
@property NSArray<IRimeCandidate *> *candidates;

@end

@interface IRimeComposition : NSObject {
  int length;
  int cursorPos;
  int selStart;
  int selEnd;
  NSString *preedit;
}

@property int length, cursorPos, selStart, selEnd;
@property NSString *preedit;

@end

@interface IRimeContext : NSObject {
  NSString *commitTextPreview;
  IRimeMenu *menu;
  IRimeComposition *composition;
  NSArray<NSString *> *labels;
}

@property NSString *commitTextPreview;
@property IRimeMenu *menu;
@property IRimeComposition *composition;
@property NSArray<NSString *> *labels;

@end

@interface IRimeConfigIteratorItem : NSObject {
  int index;
  NSString *key;
  NSString *path;
}

@property int index;
@property NSString *key;
@property NSString *path;

@end


@interface IRimeConfig : NSObject

- (NSString *)getString:(NSString *)key;
- (BOOL)getBool:(NSString *)key;
- (int)getInt:(NSString *)key;
- (BOOL)setInt:(NSString *)key value:(int) value;
- (double)getDouble:(NSString *)key;

- (NSArray<IRimeConfigIteratorItem *> *)getItems:(NSString *)key;
- (NSArray<IRimeConfigIteratorItem *> *)getMapValues:(NSString *)key;
- (void) closeConfig;
@end


