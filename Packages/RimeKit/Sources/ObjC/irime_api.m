#import "irime_api.h"
#import "../C/rime_api.h"
#import "../C/rime_levers_api.h"

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
    [notificationDelegate onLoadingSchema:@(messageValue)]];
    return;
  }

  // on changing mode:
  if (!strcmp(messageType, "option")) {
    [notificationDelegate onChangeMode:@(messageValue)]];
    return;
  }
}


@implementation IRimeStatus

- (NSString *)description {
  return
      [NSString stringWithFormat:
                    @"<%@: %p, schemaId: %@, schemaName: %@, isASCIIMode: %d, "
                    @"isASCIIPunct: %d, isComposing: %d, isDisabled: %d, "
                    @"isFullShape: %d, isSimplified: %d, isTraditional: %d>",
                    NSStringFromClass([self class]), self, _schemaId, _schemaName,
                    _isASCIIMode, _isASCIIPunct, _isComposing, _isDisabled,
                    _isFullShape, _isSimplified, _isTraditional];
}
@end

@implementation IRimeCandidate

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %p, text: %@, comment: %@>",
                                    NSStringFromClass([self class]), self, _text,
                                    _comment];
}

@end

@implementation IRimeMenu

- (NSString *)description {
  return [NSString
      stringWithFormat:@"<%@: %p, pageSize: %d, pageNo: %d, isLastPage: %c, "
                       @"highlightedCandidateIndex: %d, numCandidates %d,"
                       @"selectKeys: %@, candidates: [%@]>",
                       NSStringFromClass([self class]), self, _pageSize, _pageNo,
                       _isLastPage, _highlightedCandidateIndex, _numCandidates,
                       [_selectKeys componentsJoinedByString:@"; "]];

}

@end

@implementation IRimeComposition

- (NSString *)description {
  return
      [NSString stringWithFormat:@"<%@: %p, length: %d, cursorPos: %d, "
                                 @"selStart: %d, selEnd: %d, preedit: %@>",
                                 NSStringFromClass([self class]), self, _length,
                                 _cursorPos, _selStart, _selEnd, _preedit];
}

@end

@implementation IRimeContext

- (NSString *)description {
  return
      [NSString stringWithFormat:@"<%@: %p, commitTextPreview: %@, "
                                 @"composition: %@, labels: %@, menu: %@>",
                                 NSStringFromClass([self class]), self,
                                 _commitTextPreview, _composition, _labels,
                                 [_menu description]];
}

@end

@implementation IRimeConfig

@property RimeConfig cfg;

- (id)initWithRimeConfig:(RimeConfig)c {
  if ((self = [super init]) != nil) {
    _cfg = c;
  }
  return self;
}

- (void)closeConfig {
  RimeConfigClose(&_cfg);
}

- (NSString *)getString:(NSString *)key {
  @autoreleasepool {
    if (RimeSchemaOpen(, &_cfg))
    const char *c = RimeConfigGetCString(&_cfg, [key UTF8String]);
    if (!!c) {
      return @(c);
    }
    return nil;
  }
}

- (NSNumber *)getBool:(NSString *)key {
  @autoreleasepool {
    Bool value;
    if (!!RimeConfigGetBool(&_cfg, [key UTF8String], &value)) {
      return @(value);
    }
    return nil;
  }
}

- (NSNumber *)getInt:(NSString *)key {
  @autoreleasepool {
    int value;
    if (!!RimeConfigGetInt(&_cfg, [key UTF8String], &value)) {
      return @(value);
    }
    return nil;
  }
}

- (BOOL)setInt:(int)value forOption:(NSString *)key {
  @autoreleasepool {
    return (BOOL)RimeConfigSetInt(&_cfg, [key UTF8String], value);
  }
}

- (NSNumber *)getDouble:(NSString *)key {
  @autoreleasepool {
    double value;
    if (!!RimeConfigGetDouble(&_cfg, [key UTF8String], &value)) {
      return @(value);
    }
    return nil;
  }
}

- (NSEnumerator<IRimeConfigIteratorItem *> *)getItems:(NSString *)key {
  NSMutableArray<IRimeConfigIteratorItem *> *array = [NSMutableArray array];
  @autoreleasepool {
    RimeConfigIterator iterator;
    if (!!RimeConfigBeginList(&iterator, &_cfg, [key UTF8String])) {
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
        [item setPath:[NSString stringWithUTcF8String:iterator.path]];
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

- (void)initialize {
  RimeInitialize(NULL);
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

- (void)deployerInitialize {
  RimeDeployerInitialize(NULL);
  [self startMaintenance:YES];
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
  // TODO: 这里在启动时容易发生 crash
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

- (BOOL)processKey:(NSString *)keyCode
         inSession:(RimeSessionId)session {
  @autoreleasepool {
    unichar ch = [keycode characterAtIndex:0];
    if (ch <= 0x7f) {
      switch (ch) {
        case 0x9:
          code = XK_Tab;
          break;
        case 0xd:
          code = XK_Return;
          break;
        case 0x1b:
          code = XK_Escape
          break;
        case 0x7f:
          code = XK_BackSpace;
          break;
        case 0x20 ... 0x7e:
          code = ch;
          break;
      }
    } else if ([keyCode isEqualToString:UIKeyInputEscape]) {
      code = XK_Escape;
    } else if ([keyCode isEqualToString:UIKeyInputDelete]) {
      code = XK_Delete;
    } else if ([keyCode isEqualToString:UIKeyInputUpArrow]) {
      code = XK_Up;
    } else if ([keyCode isEqualToString:UIKeyInputDownArrow]) {
      code = XK_Down;
    } else if ([keyCode isEqualToString:UIKeyInputLeftArrow]) {
      code = XK_Left;
    } else if ([keyCode isEqualToString:UIKeyInputRightArrow]) {
      code = XK_Right;
    } else if ([keyCode isEqualToString:UIKeyInputHome]) {
      code = XK_Home;
    } else if ([keyCode isEqualToString:UIKeyInputEnd]) {
      code = XK_End;
    } else if ([keyCode isEqualToString:UIKeyInputPageUp]) {
      code = XK_Page_Up;
    } else if ([keyCode isEqualToString:UIKeyInputPageDown]) {
      code = XK_Page_Down;
    }
    return RimeProcessKey(session, code, 0);
  }
}

- (BOOL)processKeyCode:(int)code
              modifier:(int)modifier
             inSession:(RimeSessionId)session {
  return RimeProcessKey(session, code, modifier);
}

- (BOOL)setInputKeys:(NSString *)keys
         withSession:(RimeSessionId)session {
  return RimeSetInput(session, [keys UTF8String]);
}

- (NSArray<IRimeCandidate *> *)getCandidateList:(RimeSessionId)session {
  @autoreleasepool {
    RimeCandidateListIterator iterator = {0};
    if (!RimeCandidateListBegin(session, &iterator)) {
      return nil;
    }

    NSMutableArray<IRimeCandidate *> *list = [NSMutableArray array];
    while (RimeCandidateListNext(&iterator)) {
      IRimeCandidate *candidate = [[IRimeCandidate alloc] init];
      [candidate setText:@(iterator.candidate.text)];
      [candidate setComment:iterator.candidate.comment ? : @""];
      [list addObject:candidate];
    }
    RimeCandidateListEnd(&iterator);
    return list;
  }
}

- (NSArray<IRimeCandidate *> *)getCandidatesFromIndex:(int)index
                                            maxNumber:(int)limit
                                            inSession:(RimeSessionId)session {
  @autoreleasepool {
    RimeCandidateListIterator iterator = {0};
    if (!RimeCandidateListFromIndex(session, &iterator, index)) {
#if DEBUG
      NSLog(@"get candidate list error");
#endif
      return nil;
    }

    NSMutableArray<IRimeCandidate *> *candidates = [NSMutableArray arrayWithCapacity:limit];
    int maxIndex = index + limit;
    while (RimeCandidateListNext(&iterator) && iterator.index < maxIndex) {
      IRimeCandidate *candidate = [[IRimeCandidate alloc] init];
      [candidate setText:@(iterator.candidate.text)];
      [candidate setComment:iterator.candidate.comment ? : @""];
      [candidates addObject:candidate];
    }
    RimeCandidateListEnd(&iterator);
    return candidates;
  }
}

- (BOOL)selectCandidateAtIndex:(size_t)index
                     inSession:(RimeSessionId)session {
  return RimeSelectCandidate(session, index);
}

- (BOOL)deleteCandidateAtIndex:(size_t)index
                     inSession:(RimeSessionId)session {
  return RimeDeleteCandidate(session, index);
}

- (NSString *)getInput:(RimeSessionId)session {
  @autoreleasepool {
    const char *input = rime_get_api()->get_input(session);
    return input ? @(input) : @"";
  }
}

- (NSString *)getCommit:(RimeSessionId)session {
  @autoreleasepool {
    RIME_STRUCT(RimeCommit, rimeCommit);
    if (!RimeGetCommit(session, &rimeCommit)) {
      return nil;
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

- (void)clearComposition:(RimeSessionId)session {
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

      if (ctx.select_labels) {
        NSMutableArray *selectLabels = [NSMutableArray array];
        for (int i = 0; i < ctx.menu.page_size; ++i) {
          char *label_str = ctx.select_labels[i];
          [selectLabels addObject:@(label_str)];
        }
        [context setLabels:[NSArray arrayWithArray:selectLabels]];
      } else {
        [context setLabels:@[]];
      }

      // menu
      IRimeMenu *menu = [[IRimeMenu alloc] init];
      [menu setPageNo:ctx.menu.page_no];
      [menu setPageSize:ctx.menu.page_size];
      [menu setIsLastPage:ctx.menu.is_last_page];
      [menu setHighlightedCandidateIndex:ctx.menu.highlighted_candidate_index];
      [menu setNumCandidates:ctx.menu.num_candidates];
      [menu setSelectKeys:ctx.menu.select_keys ? @(ctx.menu.select_keys) : @""];

      NSMutableArray<IRimeCandidate *> *candidates = [NSMutableArray array];
      for (int i = 0; i < ctx.menu.num_candidates; i++) {
        IRimeCandidate *candidate = [[IRimeCandidate alloc] init];
        [candidate setText:@(ctx.menu.candidates[i].text)];
        [candidate setComment:ctx.menu.candidates[i].comment
                                  ? @(ctx.menu.candidates[i].comment)
                                  : @""];
        [candidates addObject:candidate];
      }
      [menu setCandidates:candidates];
      [context setMenu:menu];
    }

    RimeFreeContext(&ctx);
  }
  return context;
}

- (size_t)getCaretPosition:(RimeSessionId)session {
  size_t pos = rime_get_api()->get_caret_pos(session);
  return pos;
}

- (void)setCaretPosition:(size_t)pos inSession:(RimeSessionId)session {
  rime_get_api()->set_caret_pos(session, pos);
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

- (BOOL)selectSchema:(NSString *)schemaId forSession:(RimeSessionId)session; {
  return RimeSelectSchema(session, [schemaId UTF8String]);
}

// MARK: Configuration
- (BOOL)getOption:(NSString *)option inSession:(RimeSessionId)session {
  @autoreleasepool {
    return RimeGetOption(session, [option UTF8String]);
  }
}
- (void)setValue:(BOOL)value
       forOption:(NSString *)option
       inSession:(RimeSessionId)session {
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

- (NSString *) getStateLabelAbbreviated:(RimeSessionId) session optionName:(NSString *) option state:(BOOL)state abbreviated:(BOOL)abbreviated {
  struct rime_string_slice_t stateLabel = rime_get_api()->get_state_label_abbreviated(session, [option UTF8String], state ? 1 : 0, abbreviated ? 1 : 0);
  return stateLabel.str ? [NSString stringWithUTF8String: stateLabel.str] : @"";
}

@end
