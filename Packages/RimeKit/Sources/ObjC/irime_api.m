#import "irime_api.h"
#import "rime_api.h"
#import "rime_levers_api.h"

static id<IRimeNotificationDelegate> notificationDelegate = nil;

// 定义加载模块
// static RIME_MODULE_LIST(hamster_modules, "default", "levers", "lua");

static void rimeNotificationHandler(void *contextObject,
                                    RimeSessionId sessionId,
                                    const char *messageType,
                                    const char *messageValue) {

  if (notificationDelegate == NULL || messageValue == NULL) {
    return;
  }

  // on deployment
  if (!strcmp(messageType, "deploy")) {

    if (!strcmp(messageValue, "start")) {
      [notificationDelegate onDeployStart];
      return;
    }

    if (!strcmp(messageValue, "success")) {
      [notificationDelegate onDeploySuccess];
      return;
    }

    if (!strcmp(messageValue, "failure")) {
      [notificationDelegate onDeployFailure];
      return;
    }

    return;
  }

  // TODO: 对context_object处理
  //  id app_delegate = (__bridge id)context_object;
  //  if (app_delegate && ![app_delegate enableNotifications]) {
  //    return;
  //  }

  // on loading schema
  if (!strcmp(messageType, "schema")) {
    [notificationDelegate
        onLoadingSchema:[NSString stringWithUTF8String:messageValue]];
    return;
  }

  // on changing mode:
  if (!strcmp(messageType, "option")) {
    [notificationDelegate
        onChangeMode:[NSString stringWithUTF8String:messageValue]];
    return;
  }
}

@implementation IRimeTraits

@synthesize sharedDataDir;
@synthesize userDataDir;
@synthesize distributionName;
@synthesize distributionCodeName;
@synthesize distributionVersion;
@synthesize appName;
@synthesize modules;
@synthesize minLogLevel;
@synthesize logDir;
@synthesize prebuiltDataDir;
@synthesize stagingDir;


- (void)rimeTraits:(RimeTraits *)traits {
  if (sharedDataDir != nil) {
    traits -> shared_data_dir = [sharedDataDir UTF8String];
  }
  if (userDataDir != nil) {
    traits -> user_data_dir = [userDataDir UTF8String];
  }
  if (distributionName != nil) {
    traits -> distribution_name = [distributionName UTF8String];
  }
  if (distributionCodeName != nil) {
    traits -> distribution_code_name = [distributionCodeName UTF8String];
  }
  if (distributionVersion != nil) {
    traits -> distribution_version = [distributionVersion UTF8String];
  }
  if (appName != nil) {
    traits -> app_name = [appName UTF8String];
  }
  // 模块定义
  // traits -> modules = hamster_modules;
  if (prebuiltDataDir != nil) {
    traits -> prebuilt_data_dir = [prebuiltDataDir UTF8String];
  }
  if (stagingDir != nil) {
    traits -> staging_dir = [stagingDir UTF8String];
  }
}

@end

@implementation IRimeSchema

@synthesize schemaId, schemaName;

- (id)initWithSchemaId:(NSString *)d andSchemaName:(NSString *)name {
  if ((self = [super init]) != nil) {
    schemaId = d;
    schemaName = name;
  }
  return self;
}

- (NSString *)description {
  return
      [NSString stringWithFormat:@"id = %@, name = %@", schemaId, schemaName];
}

@end

@implementation IRimeStatus

@synthesize schemaId, schemaName;
@synthesize isASCIIMode, isASCIIPunct, isComposing, isDisabled, isFullShape,
    isSimplified, isTraditional;

- (NSString *)description {
  return
      [NSString stringWithFormat:
                    @"<%@: %p, schemaId: %@, schemaName: %@, isASCIIMode: %d, "
                    @"isASCIIPunct: %d, isComposing: %d, isDisabled: %d, "
                    @"isFullShape: %d, isSimplified: %d, isTraditional: %d>",
                    NSStringFromClass([self class]), self, schemaId, schemaName,
                    isASCIIMode, isASCIIPunct, isComposing, isDisabled,
                    isFullShape, isSimplified, isTraditional];
}
@end

@implementation IRimeCandidate

@synthesize text, comment;

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %p, text: %@, comment: %@>",
                                    NSStringFromClass([self class]), self, text,
                                    comment];
}

@end

@implementation IRimeMenu

@synthesize pageSize, pageNo, isLastPage, highlightedCandidateIndex,
    numCandidates;
@synthesize selectKeys;
@synthesize candidates;

- (NSString *)description {
  return [NSString
      stringWithFormat:@"<%@: %p, pageSize: %d, pageNo: %d, isLastPage: %@, "
                       @"highlightedCandidateIndex: %d, numCandidates %d,"
                       @"selectKeys: %@, candidates: %@>",
                       NSStringFromClass([self class]), self, pageSize, pageNo,
                       isLastPage ? @"true" : @"false",
                       highlightedCandidateIndex, numCandidates, selectKeys,
                       candidates];
}

@end

@implementation IRimeComposition

@synthesize length, cursorPos, selStart, selEnd, preedit;

- (NSString *)description {
  return
      [NSString stringWithFormat:@"<%@: %p, length: %d, cursorPos: %d, "
                                 @"selStart: %d, selEnd: %d, preedit: %@>",
                                 NSStringFromClass([self class]), self, length,
                                 cursorPos, selStart, selEnd, preedit];
}

@end

@implementation IRimeContext

@synthesize commitTextPreview;
@synthesize composition;
@synthesize menu;
@synthesize labels;

- (NSString *)description {
  return
      [NSString stringWithFormat:@"<%@: %p, commitTextPreview: %@, "
                                 @"composition: %@, labels: %@, menu: %@>",
                                 NSStringFromClass([self class]), self,
                                 commitTextPreview, composition, labels, menu];
}

@end

@implementation IRimeConfig {
  RimeConfig cfg;
}

- (id)initWithRimeConfig:(RimeConfig)c {
  if ((self = [super init]) != nil) {
    cfg = c;
  }
  return self;
}

- (void)closeConfig {
  RimeConfigClose(&cfg);
}

- (NSString *)getString:(NSString *)key {
  @autoreleasepool {
    const char *c = RimeConfigGetCString(&cfg, [key UTF8String]);
    if (!!c) {
      return [NSString stringWithUTF8String:c];
    }
    return @"";
  }
}

- (BOOL)getBool:(NSString *)key {
  @autoreleasepool {
    Bool value;
    if (!!RimeConfigGetBool(&cfg, [key UTF8String], &value)) {
      return value;
    }
    return FALSE;
  }
}

- (int)getInt:(NSString *)key {
  @autoreleasepool {
    int value;
    if (!!RimeConfigGetInt(&cfg, [key UTF8String], &value)) {
      return value;
    }
    return INT_MIN;
  }
}

- (BOOL)setInt:(NSString *)key value:(int)value {
  @autoreleasepool {
    return RimeConfigSetInt(&cfg, [key UTF8String], value);
  }
}

- (double)getDouble:(NSString *)key {
  @autoreleasepool {
    double value;
    if (!!RimeConfigGetDouble(&cfg, [key UTF8String], &value)) {
      return value;
    }
    return DBL_MIN;
  }
}

- (NSArray<IRimeConfigIteratorItem *> *)getItems:(NSString *)key {
  NSMutableArray<IRimeConfigIteratorItem *> *array = [NSMutableArray array];
  @autoreleasepool {
    RimeConfigIterator iterator;
    if (!!RimeConfigBeginList(&iterator, &cfg, [key UTF8String])) {
      while (RimeConfigNext(&iterator)) {
        IRimeConfigIteratorItem *item = [[IRimeConfigIteratorItem alloc] init];
        [item setKey:[NSString stringWithUTF8String:iterator.key]];
        [item setPath:[NSString stringWithUTF8String:iterator.path]];
        [item setIndex:iterator.index];
        [array addObject:item];
      }
      RimeConfigEnd(&iterator);
    }
  }
  return [NSArray arrayWithArray:array];
}

- (NSArray<IRimeConfigIteratorItem *> *)getMapValues:(NSString *)key {
  NSMutableArray<IRimeConfigIteratorItem *> *array = [NSMutableArray array];
  @autoreleasepool {
    RimeConfigIterator iterator;
    if (!!RimeConfigBeginMap(&iterator, &cfg, [key UTF8String])) {
      while (RimeConfigNext(&iterator)) {
        IRimeConfigIteratorItem *item = [[IRimeConfigIteratorItem alloc] init];
        [item setKey:[NSString stringWithUTF8String:iterator.key]];
        [item setPath:[NSString stringWithUTF8String:iterator.path]];
        [item setIndex:iterator.index];
        [array addObject:item];
      }
      RimeConfigEnd(&iterator);
    }
  }
  return [NSArray arrayWithArray:array];
}

@end

@implementation IRimeConfigIteratorItem

@synthesize index, key, path;

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %p, index: %d, key: %@, path: %@>",
                                    NSStringFromClass([self class]), self,
                                    index, key, path];
}

@end

// 获取 RimeLeversApi
static RimeLeversApi *get_levers() {
  return (RimeLeversApi *)(RimeFindModule("levers")->get_api());
}

// RimeEngin 实现

@implementation IRimeAPI

- (void)setNotificationDelegate:(id<IRimeNotificationDelegate>)delegate {
  notificationDelegate = delegate;
  RimeSetNotificationHandler(rimeNotificationHandler, (__bridge void *)self);
}

- (void)setup:(IRimeTraits *)traits {
  RIME_STRUCT(RimeTraits, rimeTraits);
  [traits rimeTraits:&rimeTraits];
  RimeSetup(&rimeTraits);
}

- (void)initialize:(IRimeTraits *)traits {
  if (traits == nil) {
    RimeInitialize(NULL);
  } else {
    RIME_STRUCT(RimeTraits, rimeTraits);
    [traits rimeTraits:&rimeTraits];
    RimeInitialize(&rimeTraits);
  }
}

- (void)finalize {
  RimeFinalize();
}

- (void)startMaintenance:(BOOL)fullCheck {
  // check for configuration updates
  if (RimeStartMaintenance((Bool)fullCheck) && RimeIsMaintenancing()) {
    // update squirrel config
    RimeJoinMaintenanceThread();
    RimeDeployConfigFile("squirrel.yaml", "config_version");
  }
}

- (BOOL)preBuildAllSchemas {
  return RimePrebuildAllSchemas();
}

- (void)deployerInitialize:(IRimeTraits *)traits {
  if (traits == nil) {
    RimeDeployerInitialize(NULL);
  } else {
    RIME_STRUCT(RimeTraits, rimeTraits);
    [traits rimeTraits:&rimeTraits];
    RimeDeployerInitialize(&rimeTraits);
  }
}

- (BOOL)deploy {
  return rime_get_api()->deploy();
}

// 对应lever/下deployment_task
- (BOOL)runTask:(NSString *)taskName {
  return RimeRunTask([taskName UTF8String]);
}

- (BOOL)syncUserData {
  return RimeSyncUserData();
}

- (RimeSessionId)createSession {
  return RimeCreateSession();
}

- (BOOL)findSession:(RimeSessionId)session {
  return RimeFindSession(session);
}

- (BOOL)destroySession:(RimeSessionId)session {
  return RimeDestroySession(session);
}

- (void)cleanAllSession {
  RimeCleanupAllSessions();
}

- (BOOL)processKey:(NSString *)keyCode andSession:(RimeSessionId)session {
  @autoreleasepool {
    const char *code = [keyCode UTF8String][0];
    // TODO: code转换
    return RimeProcessKey(session, code, 0);
  }
}

- (BOOL)processKeyCode:(int)code
              modifier:(int)modifier
            andSession:(RimeSessionId)session {
  return RimeProcessKey(session, code, modifier);
}

- (NSArray<IRimeCandidate *> *)getCandidateList:(RimeSessionId)session {
  @autoreleasepool {
    RimeCandidateListIterator iterator = {0};
    if (!RimeCandidateListBegin(session, &iterator)) {
      return [NSArray array];
    }

    NSMutableArray<IRimeCandidate *> *list = [NSMutableArray array];
    while (RimeCandidateListNext(&iterator)) {
      IRimeCandidate *candidate = [[IRimeCandidate alloc] init];
      [candidate setText:@(iterator.candidate.text)];
      [candidate setComment:iterator.candidate.comment
                                ? @(iterator.candidate.comment)
                                : @""];
      [list addObject:candidate];
    }
    RimeCandidateListEnd(&iterator);
    return [NSArray arrayWithArray:list];
  }
}

- (NSArray<IRimeCandidate *> *)getCandidateWithIndex:(int)index
                                            andCount:(int)count
                                          andSession:(RimeSessionId)session {
  @autoreleasepool {
    RimeCandidateListIterator iterator = {0};
    if (!RimeCandidateListFromIndex(session, &iterator, index)) {
#if DEBUG
      NSLog(@"get candidate list error");
#endif
      return [NSArray array];
    }

    NSMutableArray<IRimeCandidate *> *candidates = [NSMutableArray array];
    int maxIndex = index + count;
    while (RimeCandidateListNext(&iterator)) {
      if (iterator.index >= maxIndex) {
        break;
      }

      IRimeCandidate *candidate = [[IRimeCandidate alloc] init];
      [candidate setText:@(iterator.candidate.text)];
      [candidate setComment:iterator.candidate.comment
                                ? @(iterator.candidate.comment)
                                : @""];
      [candidates addObject:candidate];
    }
    RimeCandidateListEnd(&iterator);
    return [NSArray arrayWithArray:candidates];
  }
}

- (BOOL)selectCandidate:(RimeSessionId)session andIndex:(int)index {
  return rime_get_api()->select_candidate(session, index);
}

- (BOOL)deleteCandidate:(RimeSessionId)session andIndex:(int)index {
  return rime_get_api()->delete_candidate(session, index);
}

- (NSString *)getInput:(RimeSessionId)session {
  @autoreleasepool {
    const char *input = rime_get_api()->get_input(session);
    return input ? @(input) : @("");
  }
}

- (NSString *)getCommit:(RimeSessionId)session {
  @autoreleasepool {
    RIME_STRUCT(RimeCommit, rimeCommit);
    if (!RimeGetCommit(session, &rimeCommit)) {
      return @"";
    }
    NSString *commitText = rimeCommit.text ? @(rimeCommit.text) : @"";
    RimeFreeCommit(&rimeCommit);
    return commitText;
  }
}

- (BOOL)commitComposition:(RimeSessionId)session {
  @autoreleasepool {
    return RimeCommitComposition(session);
  }
}

- (void)cleanComposition:(RimeSessionId)session {
  @autoreleasepool {
    RimeClearComposition(session);
  }
}

- (IRimeStatus *)getStatus:(RimeSessionId)session {
  IRimeStatus *status = [[IRimeStatus alloc] init];
  @autoreleasepool {
    RIME_STRUCT(RimeStatus, rimeStatus);
    if (RimeGetStatus(session, &rimeStatus)) {
      [status setSchemaId:rimeStatus.schema_id ? @(rimeStatus.schema_id) : @""];
      [status setSchemaName:rimeStatus.schema_name ? @(rimeStatus.schema_name)
                                                   : @""];
      [status setIsASCIIMode:rimeStatus.is_ascii_mode > 0];
      [status setIsASCIIPunct:rimeStatus.is_ascii_punct > 0];
      [status setIsComposing:rimeStatus.is_composing > 0];
      [status setIsDisabled:rimeStatus.is_disabled > 0];
      [status setIsFullShape:rimeStatus.is_full_shape > 0];
      [status setIsSimplified:rimeStatus.is_simplified > 0];
      [status setIsTraditional:rimeStatus.is_traditional > 0];
    } else {
      [status setSchemaId:@""];
      [status setSchemaName:@""];
    }
    RimeFreeStatus(&rimeStatus);
  }
  return status;
}

- (IRimeContext *)getContext:(RimeSessionId)session {
  IRimeContext *context = [[IRimeContext alloc] init];

  @autoreleasepool {
    RIME_STRUCT(RimeContext, ctx);
    if (RimeGetContext(session, &ctx)) {

      const char *candidatePreview = ctx.commit_text_preview;
      [context
          setCommitTextPreview:candidatePreview ? @(candidatePreview) : @""];

      // composition
      IRimeComposition *composition = [[IRimeComposition alloc] init];
      [composition setLength:ctx.composition.length];
      [composition setCursorPos:ctx.composition.cursor_pos];
      [composition setSelStart:ctx.composition.sel_start];
      [composition setSelEnd:ctx.composition.sel_end];
      const char *preedit = ctx.composition.preedit;
      [composition setPreedit:preedit ? @(preedit) : @""];
      [context setComposition:composition];

      // 这里为了性能考虑, 先屏蔽
      // lables
      //      if (ctx.select_labels) {
      //        NSMutableArray *selectLabels = [NSMutableArray array];
      //        for (int i = 0; i < ctx.menu.page_size; ++i) {
      //          char *label_str = ctx.select_labels[i];
      //          [selectLabels addObject:@(label_str)];
      //        }
      //        [context setLabels:[NSArray arrayWithArray:selectLabels]];
      //      } else {
      //        [context setLabels:@[]];
      //      }

      // menu
      IRimeMenu *menu = [[IRimeMenu alloc] init];
      [menu setPageNo:ctx.menu.page_no];
      [menu setPageSize:ctx.menu.page_size];
      [menu setIsLastPage:ctx.menu.is_last_page];
      [menu setHighlightedCandidateIndex:ctx.menu.highlighted_candidate_index];
      [menu setNumCandidates:ctx.menu.num_candidates];
      [menu setSelectKeys:ctx.menu.select_keys ? @(ctx.menu.select_keys) : @""];

      // 分页不在使用context, 这里为了性能考虑, 先屏蔽
      //      NSMutableArray<IRimeCandidate *> *candidates = [NSMutableArray
      //      array]; for (int i = 0; i < ctx.menu.num_candidates; i++) {
      //        IRimeCandidate *candidate = [[IRimeCandidate alloc] init];
      //        [candidate setText:@(ctx.menu.candidates[i].text)];
      //        [candidate setComment:ctx.menu.candidates[i].comment
      //         ? @(ctx.menu.candidates[i].comment)
      //                             : @""];
      //        [candidates addObject:candidate];
      //      }
      //      [menu setCandidates:[NSArray arrayWithArray:candidates]];
      [context setMenu:menu];
    }
    RimeFreeContext(&ctx);
  }
  return context;
}

// MARK: Schema
- (NSArray<IRimeSchema *> *)schemaList {
  RimeSchemaList list = {0};
  if (RimeGetSchemaList(&list)) {
    size_t count = list.size;
    NSMutableArray *r = [NSMutableArray arrayWithCapacity:count];
    RimeSchemaListItem *items = list.list;
    for (int i = 0; i < count; i++) {
      RimeSchemaListItem item = items[i];
      [r addObject:[[IRimeSchema alloc] initWithSchemaId:@(item.schema_id)
                                           andSchemaName:@(item.name)]];
    }
    RimeFreeSchemaList(&list);
    return [NSArray arrayWithArray:r];
  }
  return [NSArray array];
}

- (IRimeSchema *)currentSchema:(RimeSessionId)session {
  @autoreleasepool {
    IRimeSchema *s = [[IRimeSchema alloc] init];
    RIME_STRUCT(RimeStatus, rimeStatus);
    if (RimeGetStatus(session, &rimeStatus)) {
      [s setSchemaId:@(rimeStatus.schema_id)];
      [s setSchemaName:@(rimeStatus.schema_name)];
    }
    RimeFreeStatus(&rimeStatus);
    return s;
  }
}

- (BOOL)selectSchema:(RimeSessionId)session andSchemaId:(NSString *)schemaId {
  return RimeSelectSchema(session, [schemaId UTF8String]);
}

// MARK: Configuration
- (BOOL)getOption:(RimeSessionId)session andOption:(NSString *)option {
  @autoreleasepool {
    return RimeGetOption(session, [option UTF8String]);
  }
}
- (BOOL)setOption:(RimeSessionId)session
        andOption:(NSString *)option
         andValue:(BOOL)value {
  @autoreleasepool {
    RimeSetOption(session, [option UTF8String], value ? True : False);
  }
}
- (IRimeConfig *)openConfig:(NSString *)configId {
  IRimeConfig *cfg;
  @autoreleasepool {
    RimeConfig config;
    if (!!RimeConfigOpen([configId UTF8String], &config)) {
      cfg = [[IRimeConfig alloc] initWithRimeConfig:config];
    }
  }
  return cfg;
}

- (IRimeConfig *)openSchema:(NSString *)schemaId {
  IRimeConfig *cfg;
  @autoreleasepool {
    RimeConfig config;
    if (!!RimeSchemaOpen([schemaId UTF8String], &config)) {
      cfg = [[IRimeConfig alloc] initWithRimeConfig:config];
    }
  }
  return cfg;
}

- (IRimeConfig *)openUserConfig:(NSString *)configId {
  IRimeConfig *cfg;
  @autoreleasepool {
    RimeConfig config;
    if (!!RimeUserConfigOpen([configId UTF8String], &config)) {
      cfg = [[IRimeConfig alloc] initWithRimeConfig:config];
    }
  }
  return cfg;
}

- (void)simulateKeySequence:(NSString *)keys andSession:(RimeSessionId)session {
  NSLog(@"input keys = %@", keys);
  const char *codes = [keys UTF8String];
  RimeSimulateKeySequence(session, codes);
}

- (NSArray<IRimeSchema *> *)getAvailableRimeSchemaList {
  NSMutableArray *r = [NSMutableArray array];
  @autoreleasepool {
    RimeLeversApi *levers = get_levers();
    RimeSwitcherSettings *switcher = levers->switcher_settings_init();
    RimeSchemaList list = {0};
    levers->load_settings((RimeCustomSettings *)switcher);
    levers->get_available_schema_list(switcher, &list);

    size_t count = list.size;
    RimeSchemaListItem *items = list.list;
    for (int i = 0; i < count; i++) {
      RimeSchemaListItem item = items[i];
      [r addObject:[[IRimeSchema alloc] initWithSchemaId:@(item.schema_id)
                                           andSchemaName:@(item.name)]];
    }

    levers->schema_list_destroy(&list);
    levers->custom_settings_destroy((RimeCustomSettings *)switcher);
  }
  return [NSArray arrayWithArray:r];
}

- (NSArray<IRimeSchema *> *)getSelectedRimeSchemaList {
  NSMutableArray *r = [NSMutableArray array];

  @autoreleasepool {
    RimeLeversApi *levers = get_levers();
    RimeSwitcherSettings *switcher = levers->switcher_settings_init();
    RimeSchemaList list = {0};
    levers->load_settings((RimeCustomSettings *)switcher);
    levers->get_selected_schema_list(switcher, &list);

    size_t count = list.size;
    RimeSchemaListItem *items = list.list;
    for (int i = 0; i < count; i++) {
      RimeSchemaListItem item = items[i];
      [r addObject:[[IRimeSchema alloc]
                       initWithSchemaId:@(item.schema_id)
                          andSchemaName:item.name ? @(item.name) : @""]];
    }

    levers->schema_list_destroy(&list);
    levers->custom_settings_destroy((RimeCustomSettings *)switcher);
  }

  return [NSArray arrayWithArray:r];
}

- (BOOL)selectRimeSchemas:(NSArray<NSString *> *)schemas {
  @autoreleasepool {
    int count = (int)schemas.count;
    const char *entries[count];
    for (int i = 0; i < count; i++) {
      entries[i] = [schemas[i] UTF8String];
    }

    RimeLeversApi *levers = get_levers();
    RimeSwitcherSettings *switcher = levers->switcher_settings_init();
    levers->load_settings((RimeCustomSettings *)switcher);
    BOOL handled = levers->select_schemas(switcher, entries, count);
    levers->save_settings((RimeCustomSettings *)switcher);
    levers->custom_settings_destroy((RimeCustomSettings *)switcher);
    return handled;
  }
}

- (NSString *)getHotkeys {
  RimeLeversApi *levers = get_levers();
  RimeSwitcherSettings *switcher = levers->switcher_settings_init();
  levers->load_settings((RimeCustomSettings *)switcher);
  const char *hotkeys = levers->get_hotkeys(switcher);
  NSString *key = hotkeys ? [NSString stringWithUTF8String:hotkeys] : @"";
  levers->custom_settings_destroy((RimeCustomSettings *)switcher);
  return key;
}

- (BOOL) isFirstRun {
  RimeLeversApi *levers = get_levers();
  RimeSwitcherSettings *switcher = levers->switcher_settings_init();
  levers->load_settings((RimeCustomSettings *)switcher);
  BOOL isFirstRun = levers->is_first_run((RimeCustomSettings *)switcher);
  levers->custom_settings_destroy((RimeCustomSettings *)switcher);
  return isFirstRun;
}

- (BOOL) customize:(NSString *)key boolValue:(BOOL) value {
  RimeLeversApi *levers = get_levers();
  RimeCustomSettings *switcher = (RimeCustomSettings *)(levers->switcher_settings_init());
  BOOL handled = False;
  if (levers->customize_bool(switcher, [key UTF8String], value)) {
    handled = levers->save_settings(switcher);
  }
  levers->custom_settings_destroy(switcher);
  return handled;
}

- (BOOL) customize:(NSString *)key stringValue:(NSString *) value {
  RimeLeversApi *levers = get_levers();
  RimeCustomSettings *switcher = (RimeCustomSettings *)(levers->switcher_settings_init());
  BOOL handled = False;
  if (levers->customize_string(switcher, [key UTF8String], [value UTF8String])) {
    handled = levers->save_settings(switcher);
  }
  levers->custom_settings_destroy(switcher);
  return handled;
}

- (NSString *) getCustomize:(NSString *)key {
  NSString *value = NULL;
  RimeConfig config;
  if (RimeUserConfigOpen([@"default.custom" UTF8String], &config)) {
    const char *c = RimeConfigGetCString(&config, [key UTF8String]);
    if (c) {
      value = [NSString stringWithUTF8String:c];
    }
    RimeConfigClose(&config);
  }
  return value;
}

@end
