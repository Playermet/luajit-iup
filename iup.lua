-----------------------------------------------------------
--  Binding for IUP v3.12.0
-----------------------------------------------------------
local ffi = require 'ffi'
local jit = require 'jit'


local const = {}

const.name           = 'IUP - Portable User Interface'
const.copyright      = 'Copyright (C) 1994-2014 Tecgraf, PUC-Rio.'
const.description    = 'Multi-platform toolkit for building graphical user interfaces.'
const.version        = '3.12'
const.version_number = 312000
const.version_date   = '2014/11/19'

const.error      = 1
const.noerror    = 0
const.opened     = -1
const.invalid    = -1
const.invalid_id = -10

const.ignore   = -1
const.default  = -2
const.close    = -3
const.continue = -4

const.center       = 0xFFFF
const.left         = 0xFFFE
const.right        = 0xFFFD
const.mousepos     = 0xFFFC
const.current      = 0xFFFB
const.centerparent = 0xFFFA
const.top          = const.left
const.bottom       = const.right

-- enum{IUP_SHOW, IUP_RESTORE, IUP_MINIMIZE, IUP_MAXIMIZE, IUP_HIDE};

-- enum{IUP_SBUP,   IUP_SBDN,    IUP_SBPGUP,   IUP_SBPGDN,    IUP_SBPOSV, IUP_SBDRAGV,
--      IUP_SBLEFT, IUP_SBRIGHT, IUP_SBPGLEFT, IUP_SBPGRIGHT, IUP_SBPOSH, IUP_SBDRAGH};

const.button1 = '1'
const.button2 = '2'
const.button3 = '3'
const.button4 = '4'
const.button5 = '5'

const.mask_float  = '[+/-]?(/d+/.?/d*|/./d+)'
const.mask_ufloat = '(/d+/.?/d*|/./d+)'
const.mask_efloat = '[+/-]?(/d+/.?/d*|/./d+)([eE][+/-]?/d+)?'
const.mask_int    = '[+/-]?/d+'
const.mask_uint   = '/d+'

const.getparam_ok     = -1
const.getparam_init   = -2
const.getparam_cancel = -3
const.getparam_help   = -4


local function get_const(value)
  if type(value) == 'string' then
    if const[value] then
      return const[value]
    else
      error('unknown const name', 3)
    end
  end

  return value
end


local header = [[
  typedef struct Ihandle_ Ihandle;
  typedef int (*Icallback)(Ihandle*);

  typedef int (*Iparamcb)(Ihandle* dialog, int param_index, void* user_data);

  int       IupOpen          (int *argc, char ***argv);
  void      IupClose         (void);
  void      IupImageLibOpen  (void);

  int       IupMainLoop      (void);
  int       IupLoopStep      (void);
  int       IupLoopStepWait  (void);
  int       IupMainLoopLevel (void);
  void      IupFlush         (void);
  void      IupExitLoop      (void);

  int       IupRecordInput(const char* filename, int mode);
  int       IupPlayInput(const char* filename);

  void      IupUpdate        (Ihandle* ih);
  void      IupUpdateChildren(Ihandle* ih);
  void      IupRedraw        (Ihandle* ih, int children);
  void      IupRefresh       (Ihandle* ih);
  void      IupRefreshChildren(Ihandle* ih);

  int       IupHelp          (const char* url);
  char*     IupLoad          (const char *filename);
  char*     IupLoadBuffer    (const char *buffer);

  char*     IupVersion       (void);
  char*     IupVersionDate   (void);
  int       IupVersionNumber (void);

  void      IupSetLanguage   (const char *lng);
  char*     IupGetLanguage   (void);
  void      IupSetLanguageString(const char* name, const char* str);
  void      IupStoreLanguageString(const char* name, const char* str);
  char*     IupGetLanguageString(const char* name);
  void      IupSetLanguagePack(Ihandle* ih);

  void      IupDestroy      (Ihandle* ih);
  void      IupDetach       (Ihandle* child);
  Ihandle*  IupAppend       (Ihandle* ih, Ihandle* child);
  Ihandle*  IupInsert       (Ihandle* ih, Ihandle* ref_child, Ihandle* child);
  Ihandle*  IupGetChild     (Ihandle* ih, int pos);
  int       IupGetChildPos  (Ihandle* ih, Ihandle* child);
  int       IupGetChildCount(Ihandle* ih);
  Ihandle*  IupGetNextChild (Ihandle* ih, Ihandle* child);
  Ihandle*  IupGetBrother   (Ihandle* ih);
  Ihandle*  IupGetParent    (Ihandle* ih);
  Ihandle*  IupGetDialog    (Ihandle* ih);
  Ihandle*  IupGetDialogChild(Ihandle* ih, const char* name);
  int       IupReparent     (Ihandle* ih, Ihandle* new_parent, Ihandle* ref_child);

  int       IupPopup         (Ihandle* ih, int x, int y);
  int       IupShow          (Ihandle* ih);
  int       IupShowXY        (Ihandle* ih, int x, int y);
  int       IupHide          (Ihandle* ih);
  int       IupMap           (Ihandle* ih);
  void      IupUnmap         (Ihandle *ih);

  void      IupResetAttribute(Ihandle *ih, const char* name);
  int       IupGetAllAttributes(Ihandle* ih, char** names, int n);
  Ihandle*  IupSetAtt(const char* handle_name, Ihandle* ih, const char* name, ...);
  Ihandle*  IupSetAttributes (Ihandle* ih, const char *str);
  char*     IupGetAttributes (Ihandle* ih);

  void      IupSetAttribute   (Ihandle* ih, const char* name, const char* value);
  void      IupSetStrAttribute(Ihandle* ih, const char* name, const char* value);
  void      IupSetStrf        (Ihandle* ih, const char* name, const char* format, ...);
  void      IupSetInt         (Ihandle* ih, const char* name, int value);
  void      IupSetFloat       (Ihandle* ih, const char* name, float value);
  void      IupSetDouble      (Ihandle* ih, const char* name, double value);
  void      IupSetRGB         (Ihandle *ih, const char* name, unsigned char r, unsigned char g, unsigned char b);

  char*     IupGetAttribute(Ihandle* ih, const char* name);
  int       IupGetInt      (Ihandle* ih, const char* name);
  int       IupGetInt2     (Ihandle* ih, const char* name);
  int       IupGetIntInt   (Ihandle *ih, const char* name, int *i1, int *i2);
  float     IupGetFloat    (Ihandle* ih, const char* name);
  double    IupGetDouble(Ihandle* ih, const char* name);
  void      IupGetRGB      (Ihandle *ih, const char* name, unsigned char *r, unsigned char *g, unsigned char *b);

  void  IupSetAttributeId(Ihandle *ih, const char* name, int id, const char *value);
  void  IupSetStrAttributeId(Ihandle *ih, const char* name, int id, const char *value);
  void  IupSetStrfId(Ihandle *ih, const char* name, int id, const char* format, ...);
  void  IupSetIntId(Ihandle* ih, const char* name, int id, int value);
  void  IupSetFloatId(Ihandle* ih, const char* name, int id, float value);
  void  IupSetDoubleId(Ihandle* ih, const char* name, int id, double value);
  void  IupSetRGBId(Ihandle *ih, const char* name, int id, unsigned char r, unsigned char g, unsigned char b);

  char*  IupGetAttributeId(Ihandle *ih, const char* name, int id);
  int    IupGetIntId(Ihandle *ih, const char* name, int id);
  float  IupGetFloatId(Ihandle *ih, const char* name, int id);
  double IupGetDoubleId(Ihandle *ih, const char* name, int id);
  void   IupGetRGBId(Ihandle *ih, const char* name, int id, unsigned char *r, unsigned char *g, unsigned char *b);

  void  IupSetAttributeId2(Ihandle* ih, const char* name, int lin, int col, const char* value);
  void  IupSetStrAttributeId2(Ihandle* ih, const char* name, int lin, int col, const char* value);
  void  IupSetStrfId2(Ihandle* ih, const char* name, int lin, int col, const char* format, ...);
  void  IupSetIntId2(Ihandle* ih, const char* name, int lin, int col, int value);
  void  IupSetFloatId2(Ihandle* ih, const char* name, int lin, int col, float value);
  void  IupSetDoubleId2(Ihandle* ih, const char* name, int lin, int col, double value);
  void  IupSetRGBId2(Ihandle *ih, const char* name, int lin, int col, unsigned char r, unsigned char g, unsigned char b);

  char*  IupGetAttributeId2(Ihandle* ih, const char* name, int lin, int col);
  int    IupGetIntId2(Ihandle* ih, const char* name, int lin, int col);
  float  IupGetFloatId2(Ihandle* ih, const char* name, int lin, int col);
  double IupGetDoubleId2(Ihandle* ih, const char* name, int lin, int col);
  void   IupGetRGBId2(Ihandle *ih, const char* name, int lin, int col, unsigned char *r, unsigned char *g, unsigned char *b);

  void      IupSetGlobal  (const char* name, const char* value);
  void      IupSetStrGlobal(const char* name, const char* value);
  char*     IupGetGlobal  (const char* name);

  Ihandle*  IupSetFocus     (Ihandle* ih);
  Ihandle*  IupGetFocus     (void);
  Ihandle*  IupPreviousField(Ihandle* ih);
  Ihandle*  IupNextField    (Ihandle* ih);

  Icallback IupGetCallback (Ihandle* ih, const char *name);
  Icallback IupSetCallback (Ihandle* ih, const char *name, Icallback func);
  Ihandle*  IupSetCallbacks(Ihandle* ih, const char *name, Icallback func, ...);

  Icallback IupGetFunction(const char *name);
  Icallback IupSetFunction(const char *name, Icallback func);

  Ihandle*  IupGetHandle    (const char *name);
  Ihandle*  IupSetHandle    (const char *name, Ihandle* ih);
  int       IupGetAllNames  (char** names, int n);
  int       IupGetAllDialogs(char** names, int n);
  char*     IupGetName      (Ihandle* ih);

  void      IupSetAttributeHandle(Ihandle* ih, const char* name, Ihandle* ih_named);
  Ihandle*  IupGetAttributeHandle(Ihandle* ih, const char* name);

  char*     IupGetClassName(Ihandle* ih);
  char*     IupGetClassType(Ihandle* ih);
  int       IupGetAllClasses(char** names, int n);
  int       IupGetClassAttributes(const char* classname, char** names, int n);
  int       IupGetClassCallbacks(const char* classname, char** names, int n);
  void      IupSaveClassAttributes(Ihandle* ih);
  void      IupCopyClassAttributes(Ihandle* src_ih, Ihandle* dst_ih);
  void      IupSetClassDefaultAttribute(const char* classname, const char *name, const char* value);
  int       IupClassMatch(Ihandle* ih, const char* classname);

  Ihandle*  IupCreate (const char *classname);
  Ihandle*  IupCreatev(const char *classname, void* *params);
  Ihandle*  IupCreatep(const char *classname, void *first, ...);

  /************************************************************************/
  /*                        Elements                                      */
  /************************************************************************/

  Ihandle*  IupFill       (void);
  Ihandle*  IupRadio      (Ihandle* child);
  Ihandle*  IupVbox       (Ihandle* child, ...);
  Ihandle*  IupVboxv      (Ihandle* *children);
  Ihandle*  IupZbox       (Ihandle* child, ...);
  Ihandle*  IupZboxv      (Ihandle* *children);
  Ihandle*  IupHbox       (Ihandle* child,...);
  Ihandle*  IupHboxv      (Ihandle* *children);

  Ihandle*  IupNormalizer (Ihandle* ih_first, ...);
  Ihandle*  IupNormalizerv(Ihandle* *ih_list);

  Ihandle*  IupCbox       (Ihandle* child, ...);
  Ihandle*  IupCboxv      (Ihandle* *children);
  Ihandle*  IupSbox       (Ihandle *child);
  Ihandle*  IupSplit      (Ihandle* child1, Ihandle* child2);
  Ihandle*  IupScrollBox  (Ihandle* child);
  Ihandle*  IupGridBox    (Ihandle* child, ...);
  Ihandle*  IupGridBoxv   (Ihandle **children);
  Ihandle*  IupExpander   (Ihandle *child);
  Ihandle*  IupDetachBox  (Ihandle *child);
  Ihandle*  IupBackgroundBox(Ihandle *child);

  Ihandle*  IupFrame      (Ihandle* child);

  Ihandle*  IupImage      (int width, int height, const unsigned char *pixmap);
  Ihandle*  IupImageRGB   (int width, int height, const unsigned char *pixmap);
  Ihandle*  IupImageRGBA  (int width, int height, const unsigned char *pixmap);

  Ihandle*  IupItem       (const char* title, const char* action);
  Ihandle*  IupSubmenu    (const char* title, Ihandle* child);
  Ihandle*  IupSeparator  (void);
  Ihandle*  IupMenu       (Ihandle* child,...);
  Ihandle*  IupMenuv      (Ihandle* *children);

  Ihandle*  IupButton     (const char* title, const char* action);
  Ihandle*  IupCanvas     (const char* action);
  Ihandle*  IupDialog     (Ihandle* child);
  Ihandle*  IupUser       (void);
  Ihandle*  IupLabel      (const char* title);
  Ihandle*  IupList       (const char* action);
  Ihandle*  IupText       (const char* action);
  Ihandle*  IupMultiLine  (const char* action);
  Ihandle*  IupToggle     (const char* title, const char* action);
  Ihandle*  IupTimer      (void);
  Ihandle*  IupClipboard  (void);
  Ihandle*  IupProgressBar(void);
  Ihandle*  IupVal        (const char *type);
  Ihandle*  IupTabs       (Ihandle* child, ...);
  Ihandle*  IupTabsv      (Ihandle* *children);
  Ihandle*  IupTree       (void);
  Ihandle*  IupLink       (const char* url, const char* title);


  /************************************************************************/
  /*                      Utilities                                       */
  /************************************************************************/

  /* IupImage utility */
  int IupSaveImageAsText(Ihandle* ih, const char* file_name, const char* format, const char* name);

  /* IupText and IupScintilla utilities */
  void  IupTextConvertLinColToPos(Ihandle* ih, int lin, int col, int *pos);
  void  IupTextConvertPosToLinCol(Ihandle* ih, int pos, int *lin, int *col);

  /* IupText, IupList, IupTree, IupMatrix and IupScintilla utility */
  int   IupConvertXYToPos(Ihandle* ih, int x, int y);

  /* IupTree utilities */
  int   IupTreeSetUserId(Ihandle* ih, int id, void* userid);
  void* IupTreeGetUserId(Ihandle* ih, int id);
  int   IupTreeGetId(Ihandle* ih, void *userid);
  void  IupTreeSetAttributeHandle(Ihandle* ih, const char* name, int id, Ihandle* ih_named);


  /************************************************************************/
  /*                      Pre-definided dialogs                           */
  /************************************************************************/

  Ihandle* IupFileDlg(void);
  Ihandle* IupMessageDlg(void);
  Ihandle* IupColorDlg(void);
  Ihandle* IupFontDlg(void);
  Ihandle* IupProgressDlg(void);

  int  IupGetFile(char *arq);
  void IupMessage(const char *title, const char *msg);
  void IupMessagef(const char *title, const char *format, ...);
  int  IupAlarm(const char *title, const char *msg, const char *b1, const char *b2, const char *b3);
  int  IupScanf(const char *format, ...);
  int  IupListDialog(int type, const char *title, int size, const char** list,
                     int op, int max_col, int max_lin, int* marks);
  int  IupGetText(const char* title, char* text);
  int  IupGetColor(int x, int y, unsigned char* r, unsigned char* g, unsigned char* b);

  int IupGetParam(const char* title, Iparamcb action, void* user_data, const char* format,...);
  int IupGetParamv(const char* title, Iparamcb action, void* user_data, const char* format, int param_count, int param_extra, void** param_data);

  Ihandle* IupLayoutDialog(Ihandle* dialog);
  Ihandle* IupElementPropertiesDialog(Ihandle* elem);
]]

local bind = {}
local help = {}
local mod = {}

function mod.open()
  -- skip argc and argv
  return bind.IupOpen(nil, nil)
end

function mod.close()
  bind.IupClose()
end

function mod.image_lib_open()
  bind.IupImageLibOpen()
end

function mod.main_loop()
  return bind.IupMainLoop()
end

function mod.loop_step()
  return bind.IupLoopStep()
end

function mod.loop_step_wait()
  return bind.IupLoopStepWait()
end

function mod.main_loop_level()
  return bind.IupMainLoopLevel()
end

function mod.flush()
  bind.IupFlush()
end

function mod.exit_loop()
  bind.IupExitLoop()
end

function mod.record_input(filename, mode)
  return bind.IupRecordInput(filename, mode)
end

function mod.play_input(filename)
  return bind.IupPlayInput(filename)
end

function mod.update(ih)
  bind.IupUpdate(ih)
end

function mod.update_children(ih)
  bind.IupUpdateChildren(ih)
end

function mod.redraw(ih, children)
  bind.IupRedraw(ih, children)
end

function mod.refresh(ih)
  bind.IupRefresh(ih)
end

function mod.refresh_children(ih)
  bind.IupRefreshChildren(ih)
end

function mod.help(url)
  return bind.IupHelp(url)
end

function mod.load(filename)
  local err = bind.IupLoad(filename)
  return (err ~= nil) and ffi.string(err) or nil
end

function mod.load_buffer(buffer)
  local err = bind.IupLoadBuffer(buffer)
  return (err ~= nil) and ffi.string(err) or nil
end

function mod.version()
  return ffi.string(bind.IupVersion())
end

function mod.version_date()
  return ffi.string(bind.IupVersionDate())
end

function mod.version_number()
  return bind.IupVersionNumber()
end

function mod.set_language(lng)
  bind.IupSetLanguage(lng)
end

function mod.get_language()
  return ffi.string(bind.IupGetLanguage())
end

function mod.set_language_string(name, str)
  bind.IupSetLanguageString(name, str)
end

function mod.store_language_string(name, str)
  bind.IupStoreLanguageString(name, str)
end

function mod.get_language_string(name)
  return ffi.string(bind.IupGetLanguageString(name))
end

function mod.set_language_pack(ih)
  bind.IupSetLanguagePack(ih)
end

function mod.destroy(ih)
  bind.IupDestroy(ih)
end

function mod.detach(child)
  bind.IupDetach(child)
end

function mod.append(ih, child)
  return bind.IupAppend(ih, child)
end

function mod.insert(ih, ref_child, child)
  return bind.IupInsert(ih, ref_child, child)
end

function mod.get_child(ih, pos)
  return bind.IupGetChild(ih, pos)
end

function mod.get_child_pos(ih, child)
  return bind.IupGetChildPos(ih, child)
end

function mod.get_child_count(ih)
  return bind.IupGetChildCount(ih)
end

function mod.get_next_child(ih, child)
  return bind.IupGetNextChild(ih, child)
end

function mod.get_brother(ih)
  return bind.IupGetBrother(ih)
end

function mod.get_parent(ih)
  return bind.IupGetParent(ih)
end

function mod.get_dialog(ih)
  return bind.IupGetDialog(ih)
end

function mod.get_dialog_child(ih, name)
  return bind.IupGetDialogChild(ih, name)
end

function mod.reparent(ih, new_parent, ref_child)
  return bind.IupReparent(ih, new_parent, ref_child)
end

function mod.popup(ih, x, y)
  return bind.IupPopup(ih, x, y)
end

function mod.show(ih)
  return bind.IupShow(ih)
end

function mod.show_xy(ih, x, y)
  return bind.IupShowXY(ih, x, y)
end

function mod.hide(ih)
  return bind.IupHide(ih)
end

function mod.map(ih)
  return bind.IupMap(ih)
end

function mod.unmap(ih)
  bind.IupUnmap(ih)
end

function mod.reset_attribute(ih, name)
  bind.IupResetAttribute(ih, name)
end

function mod.get_all_attributes(ih)
  local count = bind.IupGetAllAttributes(ih, nil, 0)
  local cdata = ffi.new('char*[?]', count)

  bind.IupGetAllAttributes(ih, cdata, count)

  local attributes = {}
  for i = 0, count - 1 do
    -- invalid count fix
    if cdata[i] ~= nil then
      table.insert(attributes, ffi.string(cdata[i]))
    end
  end

  return attributes
end

function mod.set_att(handle_name, ih, name, ...)
  name = help.attrname(name)
  return bind.IupSetAtt(handle_name, ih, name, help.vararg(...))
end

function mod.set_attributes(ih, str)
  return bind.IupSetAttributes(ih, str)
end

function mod.get_attributes(ih)
  return ffi.string(bind.IupGetAttributes(ih))
end

function mod.set_attribute(ih, name, value)
  name = help.attrname(name)
  value = help.attrvalue(value)
  bind.IupSetAttribute(ih, name, value)
end

function mod.set_str_attribute(ih, name, value)
  name = help.attrname(name)
  bind.IupSetStrAttribute(ih, name, value)
end

function mod.set_strf(ih, name, format, ...)
  name = help.attrname(name)
  local value = string.format(format, ...)
  bind.IupSetAttribute(ih, name, value)
end

function mod.set_int(ih, name, value)
  name = help.attrname(name)
  bind.IupSetInt(ih, name, value)
end

function mod.set_float(ih, name, value)
  name = help.attrname(name)
  bind.IupSetFloat(ih, name, value)
end

function mod.set_double(ih, name, value)
  name = help.attrname(name)
  bind.IupSetDouble(ih, name, value)
end

function mod.set_rgb(ih, name, r, g, b)
  name = help.attrname(name)
  bind.IupSetRGB(ih, name, r, g, b)
end

function mod.get_attribute(ih, name)
  name = help.attrname(name)
  return ffi.string(bind.IupGetAttribute(ih, name))
end

function mod.get_int(ih, name)
  name = help.attrname(name)
  return bind.IupGetInt(ih, name)
end

function mod.get_int2(ih, name)
  name = help.attrname(name)
  return bind.IupGetInt2(ih, name)
end

function mod.get_int_int(ih, name)
  name = help.attrname(name)

  local i1 = ffi.new('int[1]')
  local i2 = ffi.new('int[1]')

  bind.IupGetIntInt(ih, name, i1, i2)

  return i1[0], i2[0]
end

function mod.get_float(ih, name)
  name = help.attrname(name)
  return bind.IupGetFloat(ih, name)
end

function mod.get_double(ih, name)
  name = help.attrname(name)
  return bind.IupGetDouble(ih, name)
end

function mod.get_rgb(ih, name)
  name = help.attrname(name)

  local r = ffi.new('unsigned char[1]')
  local g = ffi.new('unsigned char[1]')
  local b = ffi.new('unsigned char[1]')

  bind.IupGetRGB(ih, name, r, g, b)

  return r[0], g[0], b[0]
end

function mod.set_attribute_id(ih, name, id, value)
  name = help.attrname(name)
  bind.IupSetAttributeId(ih, name, id, value)
end

function mod.set_str_attribute_id(ih, name, id, value)
  name = help.attrname(name)
  bind.IupSetStrAttributeId(ih, name, id, value)
end

function mod.set_strf_id(ih, name, id, format, ...)
  name = help.attrname(name)
  local value = string.format(format, ...)
  bind.IupSetAttributeId(ih, name, id, value)
end

function mod.set_int_id(ih, name, id, value)
  name = help.attrname(name)
  bind.IupSetIntId(ih, name, id, value)
end

function mod.set_float_id(ih, name, id, value)
  name = help.attrname(name)
  bind.IupSetFloatId(ih, name, id, value)
end

function mod.set_double_id(ih, name, id, value)
  name = help.attrname(name)
  bind.IupSetDoubleId(ih, name, id, value)
end

function mod.set_rgb_id(ih, name, id, r, g, b)
  name = help.attrname(name)
  bind.IupSetRGBId(ih, name, id, r, g, b)
end

function mod.get_attribute_id(ih, name, id)
  name = help.attrname(name)
  return ffi.string(bind.IupGetAttributeId(ih, name, id))
end

function mod.get_int_id(ih, name, id)
  name = help.attrname(name)
  return bind.IupGetIntId(ih, name, id)
end

function mod.get_float_id(ih, name, id)
  name = help.attrname(name)
  return bind.IupGetFloatId(ih, name, id)
end

function mod.get_double_id(ih, name, id)
  name = help.attrname(name)
  return bind.IupGetDoubleId(ih, name, id)
end

function mod.get_rgb_id(ih, name, id)
  name = help.attrname(name)

  local r = ffi.new('unsigned char[1]')
  local g = ffi.new('unsigned char[1]')
  local b = ffi.new('unsigned char[1]')

  bind.IupGetRGBId(ih, name, id, r, g, b)

  return r[0], g[0], b[0]
end

function mod.set_attribute_id2(ih, name, lin, col, value)
  name = help.attrname(name)
  bind.IupSetAttributeId2(ih, name, lin, col, value)
end

function mod.set_str_attribute_id2(ih, name, lin, col, value)
  name = help.attrname(name)
  bind.IupSetStrAttributeId2(ih, name, lin, col, value)
end

function mod.set_strf_id2(ih, name, lin, col, format, ...)
  name = help.attrname(name)
  local value = string.format(format, ...)
  bind.IupSetAttributeId2(ih, name, lin, col, value)
end

function mod.set_int_id2(ih, name, lin, col, value)
  name = help.attrname(name)
  bind.IupSetIntId2(ih, name, lin, col, value)
end

function mod.set_float_id2(ih, name, lin, col, value)
  name = help.attrname(name)
  bind.IupSetFloatId2(ih, name, lin, col, value)
end

function mod.set_double_id2(ih, name, lin, col, value)
  name = help.attrname(name)
  bind.IupSetDoubleId2(ih, name, lin, col, value)
end

function mod.set_rgb_id2(ih, name, lin, col, r, g, b)
  name = help.attrname(name)
  bind.IupSetRGBId2(ih, name, lin, col, r, g, b)
end

function mod.get_attribute_id2(ih, name, lin, col)
  name = help.attrname(name)
  return ffi.string(bind.IupGetAttributeId2(ih, name, lin, col))
end

function mod.get_int_id2(ih, name, lin, col)
  name = help.attrname(name)
  return bind.IupGetIntId2(ih, name, lin, col)
end

function mod.get_float_id2(ih, name, lin, col)
  name = help.attrname(name)
  return bind.IupGetFloatId2(ih, name, lin, col)
end

function mod.get_double_id2(ih, name, lin, col)
  name = help.attrname(name)
  return bind.IupGetDoubleId2(ih, name, lin, col)
end

function mod.get_rgb_id2(ih, name, lin, col)
  name = help.attrname(name)

  local r = ffi.new('unsigned char[1]')
  local g = ffi.new('unsigned char[1]')
  local b = ffi.new('unsigned char[1]')

  bind.IupGetRGBId2(ih, name, lin, col, r, g, b)

  return r[0], g[0], b[0]
end

function mod.set_global(name, value)
  name = help.attrname(name)
  bind.IupSetGlobal(name, value)
end

function mod.set_str_global(name, value)
  name = help.attrname(name)
  bind.IupSetStrGlobal(name, value)
end

function mod.get_global(name)
  name = help.attrname(name)
  return ffi.string(bind.IupGetGlobal(name))
end

function mod.set_focus(ih)
  return bind.IupSetFocus(ih)
end

function mod.get_focus()
  return bind.IupGetFocus()
end

function mod.previous_field(ih)
  return bind.IupPreviousField(ih)
end

function mod.next_field(ih)
  return bind.IupNextField(ih)
end

function mod.get_callback(ih, name)
  name = help.attrname(name)
  return bind.IupGetCallback(ih, name)
end

function mod.set_callback(ih, name, func)
--  Icallback IupSetCallback (Ihandle* ih, const char *name, Icallback func)
  name = help.attrname(name)
  return bind.IupSetCallback(ih, name, ffi.cast('Icallback',func))
end

function mod.set_callbacks(ih, name, func, ...)
--  Ihandle* IupSetCallbacks(Ihandle* ih, const char *name, Icallback func, ...)
  return bind.IupSetCallbacks(ih, name, func, ...)
end

function mod.get_function(name)
  name = help.attrname(name)
  return bind.IupGetFunction(name)
end

function mod.set_function(name, func)
--  Icallback IupSetFunction(const char *name, Icallback func)
  name = help.attrname(name)
  return bind.IupSetFunction(name, func)
end

function mod.get_handle(name)
  return bind.IupGetHandle(name)
end

function mod.set_handle(name, ih)
  return bind.IupSetHandle(name, ih)
end

function mod.get_all_names()
  local count = bind.IupGetAllNames(nil, 0)
  local cdata = ffi.new('char*[?]', count)

  bind.IupGetAllNames(cdata, count)

  local names = {}
  for i = 0, count - 1 do
    table.insert(names, ffi.string(cdata[i]))
  end

  return names
end

function mod.get_all_dialogs()
  local count = bind.IupGetAllDialogs(nil, 0)
  local cdata = ffi.new('char*[?]', count)

  bind.IupGetAllDialogs(cdata, count)

  local dialogs = {}
  for i = 0, count - 1 do
    table.insert(dialogs, ffi.string(cdata[i]))
  end

  return dialogs
end

function mod.get_name(ih)
  local r = bind.IupGetName(ih)
  return (r ~= nil) and ffi.string(r) or nil
end

function mod.set_attribute_handle(ih, name, ih_named)
  name = help.attrname(name)
  bind.IupSetAttributeHandle(ih, name, ih_named)
end

function mod.get_attribute_handle(ih, name)
  name = help.attrname(name)
  return bind.IupGetAttributeHandle(ih, name)
end

function mod.get_class_name(ih)
  return ffi.string(bind.IupGetClassName(ih))
end

function mod.get_class_type(ih)
  return ffi.string(bind.IupGetClassType(ih))
end

function mod.get_all_classes()
  local count = bind.IupGetAllClasses(nil, 0)
  local cdata = ffi.new('char*[?]', count)

  bind.IupGetAllClasses(cdata, count)

  local classes = {}
  for i = 0, count - 1 do
    table.insert(classes, ffi.string(cdata[i]))
  end

  return classes
end

function mod.get_class_attributes(classname)
  local count = bind.IupGetClassAttributes(classname, nil, 0)

  -- class not found
  if count == -1 then
    return
  end

  local cdata = ffi.new('char*[?]', count)

  bind.IupGetClassAttributes(classname, cdata, count)

  local attributes = {}
  for i = 0, count - 1 do
    -- invalid count fix
    if cdata[i] ~= nil then
      table.insert(attributes, ffi.string(cdata[i]))
    end
  end

  return attributes
end

function mod.get_class_callbacks(classname)
  local count = bind.IupGetClassCallbacks(classname, nil, 0)

  -- class not found
  if count == -1 then
    return
  end

  local cdata = ffi.new('char*[?]', count)

  bind.IupGetClassCallbacks(classname, cdata, count)

  local callbacks = {}
  for i = 0, count - 1 do
    -- invalid count fix
    if cdata[i] ~= nil then
      table.insert(callbacks, ffi.string(cdata[i]))
    end
  end

  return callbacks
end

function mod.save_class_attributes(ih)
  bind.IupSaveClassAttributes(ih)
end

function mod.copy_class_attributes(src_ih, dst_ih)
  bind.IupCopyClassAttributes(src_ih, dst_ih)
end

function mod.set_class_default_attribute(classname, name, value)
  name = help.attrname(name)
  bind.IupSetClassDefaultAttribute(classname, name, value)
end

function mod.class_match(ih, classname)
  return bind.IupClassMatch(ih, classname)
end

function mod.create(classname)
  return bind.IupCreate(classname)
end

function mod.createv(classname, params)
  params = help.vararr('void*', params)
  return bind.IupCreatev(classname, params)
end

function mod.createp(classname, first, ...)
  return bind.IupCreatep(classname, first, help.vararg(...))
end

function mod.fill()
  return bind.IupFill()
end

function mod.radio(child)
  return bind.IupRadio(child)
end

function mod.vbox(child, ...)
  return bind.IupVbox(child, help.vararg(...))
end

function mod.vboxv(children)
  children = help.vararr('Ihandle*', children)
  return bind.IupVboxv(children)
end

function mod.zbox(child, ...)
  return bind.IupZbox(child, help.vararg(...))
end

function mod.zboxv(children)
  children = help.vararr('Ihandle*', children)
  return bind.IupZboxv(children)
end

function mod.hbox(child, ...)
  return bind.IupHbox(child, help.vararg(...))
end

function mod.hboxv(children)
  children = help.vararr('Ihandle*', children)
  return bind.IupHboxv(children)
end

function mod.normalizer(ih_first, ...)
  return bind.IupNormalizer(ih_first, help.vararg(...))
end

function mod.normalizerv(ih_list)
  ih_list = help.vararr('Ihandle*', ih_list)
  return bind.IupNormalizerv(ih_list)
end

function mod.cbox(child, ...)
  return bind.IupCbox(child, help.vararg(...))
end

function mod.cboxv(children)
  children = help.vararr('Ihandle*', children)
  return bind.IupCboxv(children)
end

function mod.sbox(child)
  return bind.IupSbox(child)
end

function mod.split(child1, child2)
  return bind.IupSplit(child1, child2)
end

function mod.scroll_box(child)
  return bind.IupScrollBox(child)
end

function mod.grid_box(child, ...)
  return bind.IupGridBox(child, help.vararg(...))
end

function mod.grid_boxv(children)
  children = help.vararr('Ihandle*', children)
  return bind.IupGridBoxv(children)
end

function mod.expander(child)
  return bind.IupExpander(child)
end

function mod.detach_box(child)
  return bind.IupDetachBox(child)
end

function mod.background_box(child)
  return bind.IupBackgroundBox(child)
end

function mod.frame(child)
  return bind.IupFrame(child)
end

function mod.image(width, height, pixmap)
  if type(pixmap) == 'table' then
    local size = width * height
    pixmap = ffi.new('const unsigned char[?]', size, pixmap)
  end
  -- iup copy image data, so no need to keep it
  return bind.IupImage(width, height, pixmap)
end

function mod.image_rgb(width, height, pixmap)
  if type(pixmap) == 'table' then
    local size = width * height * 3
    pixmap = ffi.new('const unsigned char[?]', size, pixmap)
  end
  -- iup copy image data, so no need to keep it
  return bind.IupImageRGB(width, height, pixmap)
end

function mod.image_rgba(width, height, pixmap)
  if type(pixmap) == 'table' then
    local size = width * height * 4
    pixmap = ffi.new('const unsigned char[?]', size, pixmap)
  end
  -- iup copy image data, so no need to keep it
  return bind.IupImageRGBA(width, height, pixmap)
end

function mod.item(title, action)
  return bind.IupItem(title, action)
end

function mod.submenu(title, child)
  return bind.IupSubmenu(title, child)
end

function mod.separator()
  return bind.IupSeparator()
end

function mod.menu(child, ...)
  return bind.IupMenu(child, help.vararg(...))
end

function mod.menuv(children)
  children = help.vararr('Ihandle*', children)
  return bind.IupMenuv(children)
end

function mod.button(title, action)
  return bind.IupButton(title, action)
end

function mod.canvas(action)
  return bind.IupCanvas(action)
end

function mod.dialog(child)
  return bind.IupDialog(child)
end

function mod.user()
  return bind.IupUser()
end

function mod.label(title)
  return bind.IupLabel(title)
end

function mod.list(action)
  return bind.IupList(action)
end

function mod.text(action)
  return bind.IupText(action)
end

function mod.multi_line(action)
  return bind.IupMultiLine(action)
end

function mod.toggle(title, action)
  return bind.IupToggle(title, action)
end

function mod.timer()
  return bind.IupTimer()
end

function mod.clipboard()
  return bind.IupClipboard()
end

function mod.progress_bar()
  return bind.IupProgressBar()
end

function mod.val(type)
  return bind.IupVal(type)
end

function mod.tabs(child, ...)
  return bind.IupTabs(child, help.vararg(...))
end

function mod.tabsv(children)
  children = help.vararr('Ihandle*', children)
  return bind.IupTabsv(children)
end

function mod.tree()
  return bind.IupTree()
end

function mod.link(url, title)
  return bind.IupLink(url, title)
end

function mod.save_image_as_text(ih, file_name, format, name)
  return bind.IupSaveImageAsText(ih, file_name, format, name)
end

function mod.text_convert_lin_col_to_pos(ih, lin, col)
  local pos = ffi.new('int[1]')

  bind.IupTextConvertLinColToPos(ih, lin, col, pos)

  return pos[0]
end

function mod.text_convert_pos_to_lin_col(ih, pos)
  local lin = ffi.new('int[1]')
  local col = ffi.new('int[1]')

  bind.IupTextConvertPosToLinCol(ih, pos, lin, col)

  return lin[0], col[0]
end

function mod.convert_xy_to_pos(ih, x, y)
  return bind.IupConvertXYToPos(ih, x, y)
end

function mod.tree_set_user_id(ih, id, userid)
  return bind.IupTreeSetUserId(ih, id, userid)
end

function mod.tree_get_user_id(ih, id)
  return bind.IupTreeGetUserId(ih, id)
end

function mod.tree_get_id(ih, userid)
  return bind.IupTreeGetId(ih, userid)
end

function mod.tree_set_attribute_handle(ih, name, id, ih_named)
  name = help.attrname(name)
  bind.IupTreeSetAttributeHandle(ih, name, id, ih_named)
end

function mod.file_dlg()
  return bind.IupFileDlg()
end

function mod.message_dlg()
  return bind.IupMessageDlg()
end

function mod.color_dlg()
  return bind.IupColorDlg()
end

function mod.font_dlg()
  return bind.IupFontDlg()
end

function mod.progress_dlg()
  return bind.IupProgressDlg()
end

function mod.get_file(arq)
  return bind.IupGetFile(arq)
end

function mod.message(title, msg)
  bind.IupMessage(title, msg)
end

function mod.messagef(title, format, ...)
  local msg = string.format(format, ...)
  bind.IupMessage(title, msg)
end

function mod.alarm(title, msg, b1, b2, b3)
  return bind.IupAlarm(title, msg, b1, b2, b3)
end

-- function mod.list_dialog(type, title, size, list, op, max_col, max_lin, marks)
-- --  int IupListDialog(int type, const char *title, int size, const char** list, int op, int max_col, int max_lin, int* marks)
--   return bind.IupListDialog(type, title, size, list, op, max_col, max_lin, marks)
-- end

function mod.get_text(title, text)
  return bind.IupGetText(title, text)
end

-- function mod.get_color(x, y, r, g, b)
-- --  int IupGetColor(int x, int y, unsigned char* r, unsigned char* g, unsigned char* b)
--   return bind.IupGetColor(x, y, r, g, b)
-- end

-- function mod.get_param(title, action, user_data, format, ...)
-- --  int IupGetParam(const char* title, Iparamcb action, void* user_data, const char* format,...)
--   return bind.IupGetParam(title, action, user_data, format, ...)
-- end

-- function mod.get_paramv(title, action, user_data, format, param_count, param_extra, param_data)
-- --  int IupGetParamv(const char* title, Iparamcb action, void* user_data, const char* format, int param_count, int param_extra, void** param_data)
--   return bind.IupGetParamv(title, action, user_data, format, param_count, param_extra, param_data)
-- end

function mod.layout_dialog(dialog)
  return bind.IupLayoutDialog(dialog)
end

function mod.element_properties_dialog(elem)
  return bind.IupElementPropertiesDialog(elem)
end


function mod.isshift(s)
  return help.strchar(s,0) == 'S'
end

function mod.iscontrol(s)
  return help.strchar(s,1) == 'C'
end

function mod.isbutton1(s)
  return help.strchar(s,2) == '1'
end

function mod.isbutton2(s)
  return help.strchar(s,3) == '2'
end

function mod.isbutton3(s)
  return help.strchar(s,4) == '3'
end

function mod.isdouble(s)
  return help.strchar(s,5) == 'D'
end

function mod.isalt(s)
  return help.strchar(s,6) == 'A'
end

function mod.issys(s)
  return help.strchar(s,7) == 'Y'
end

function mod.isbutton4(status)
  return help.strchar(s,8) == '4'
end

function mod.isbutton5(status)
  return help.strchar(s,9) == '5'
end


local cb = {}

function cb.action(func)
  return cb.action_raw(function(ih)
    return func(ih) or const.default
  end)
end

function cb.action(func)
  return cb.action_raw(function(ih)
    return func(ih) or const.default
  end)
end

function cb.getfocus_cb(func)
  return cb.getfocus_cb_raw(function(ih)
    return func(ih) or const.default
  end)
end

function cb.killfocus_cb(func)
  return cb.killfocus_cb_raw(function(ih)
    return func(ih) or const.default
  end)
end

function cb.k_any(func)
  return cb.k_any_raw(function(ih, c)
    return func(ih, c) or const.default
  end)
end

function cb.keypress_cb(func)
  return cb.keypress_cb_raw(function(ih, c, press)
    return func(ih, c, press) or const.default
  end)
end

function cb.help_cb(func)
  return cb.help_cb_raw(function(ih)
    return func(ih) or const.default
  end)
end

function cb.scroll_cb(func)
  return cb.scroll_cb_raw(function(ih, op, posx, posy)
    return func(ih, op, posx, posy) or const.default
  end)
end

function cb.resize_cb(func)
  return cb.resize_cb_raw(function(ih, width, height)
    return func(ih, width, height) or const.default
  end)
end

function cb.motion_cb(func)
  return cb.motion_cb_raw(function(ih, x, y, status)
    status = ffi.string(status)
    return func(ih, x, y, status) or const.default
  end)
end

function cb.button_cb(func)
  return cb.button_cb_raw(function(ih, button, pressed, x, y, status)
    status = ffi.string(status)
    return func(ih, button, pressed, x, y, status) or const.default
  end)
end

function cb.enterwindow_cb(func)
  return cb.enterwindow_cb_raw(function(ih)
    return func(ih) or const.default
  end)
end

function cb.leavewindow_cb(func)
  return cb.leavewindow_cb_raw(function(ih)
    return func(ih) or const.default
  end)
end

function cb.wheel_cb(func)
  return cb.wheel_cb_raw(function(ih, delta, x, y, status)
    status = ffi.string(status)
    return func(ih, delta, x, y, status) or const.default
  end)
end

function cb.open_cb(func)
  return cb.open_cb_raw(function(ih)
    return func(ih) or const.default
  end)
end

function cb.highlight_cb(func)
  return cb.highlight_cb_raw(function(ih)
    return func(ih) or const.default
  end)
end

function cb.menuclose_cb(func)
  return cb.menuclose_cb_raw(function(ih)
    return func(ih) or const.default
  end)
end

function cb.map_cb(func)
  return cb.map_cb_raw(function(ih)
    return func(ih) or const.default
  end)
end

function cb.unmap_cb(func)
  return cb.unmap_cb_raw(function(ih)
    return func(ih) or const.default
  end)
end

function cb.close_cb(func)
  return cb.close_cb_raw(function(ih)
    return func(ih) or const.default
  end)
end

function cb.show_cb(func)
  return cb.show_cb_raw(function(ih, state)
    return func(ih, state) or const.default
  end)
end

function cb.dropfiles_cb(func)
  return cb.dropfiles_cb_raw(function(ih, filename, num, x, y)
    filename = ffi.string(filename)
    return func(ih, filename, num, x, y) or const.default
  end)
end

function cb.wom_cb(func)
  return cb.wom_cb_raw(function(ih, state)
    return func(ih, state) or const.default
  end)
end


cb.action_raw         = 'int (*)(Ihandle*)'
cb.getfocus_cb_raw    = 'int (*)(Ihandle*)'
cb.killfocus_cb_raw   = 'int (*)(Ihandle*)'
cb.k_any_raw          = 'int (*)(Ihandle*,int)'
cb.keypress_cb_raw    = 'int (*)(Ihandle*,int,int)'
cb.help_cb_raw        = 'int (*)(Ihandle*)'

cb.scroll_cb_raw      = 'int (*)(Ihandle*,int,float,float)'
cb.resize_cb_raw      = 'int (*)(Ihandle*,int,int)'
cb.motion_cb_raw      = 'int (*)(Ihandle*,int,int,char*)'
cb.button_cb_raw      = 'int (*)(Ihandle*,int,int,int,int,char*)'
cb.enterwindow_cb_raw = 'int (*)(Ihandle*)'
cb.leavewindow_cb_raw = 'int (*)(Ihandle*)'
cb.wheel_cb_raw       = 'int (*)(Ihandle*,float,int,int,char*)'

cb.open_cb_raw        = 'int (*)(Ihandle*)'
cb.highlight_cb_raw   = 'int (*)(Ihandle*)'
cb.menuclose_cb_raw   = 'int (*)(Ihandle*)'

cb.map_cb_raw         = 'int (*)(Ihandle*)'
cb.unmap_cb_raw       = 'int (*)(Ihandle*)'
cb.close_cb_raw       = 'int (*)(Ihandle*)'
cb.show_cb_raw        = 'int (*)(Ihandle*,int)'

cb.dropfiles_cb_raw   = 'int (*)(Ihandle*,const char*,int,int,int)'
cb.wom_cb_raw         = 'int (*)(Ihandle*,int)'


local builder_mt = {}

function builder_mt:__index(name)
  return function(t)
    local ih = mod.create(name)
    help.set_attributes_table(ih, t)
    return ih
  end
end

local builder = setmetatable({}, builder_mt)

function builder.image(t)
  local ih = mod.image(t.width, t.height, t.pixels)
  help.set_attributes_table(ih, t)
  return ih
end

function builder.image_rgb(t)
  local ih = mod.image_rgb(t.width, t.height, t.pixels)
  help.set_attributes_table(ih, t)
  return ih
end

function builder.image_rgba(t)
  local ih = mod.image_rgba(t.width, t.height, t.pixels)
  help.set_attributes_table(ih, t)
  return ih
end


function help.vararg(...)
  local t = { ... }
  -- define the end of the list
  t[#t + 1] = 0
  return unpack(t)
end

function help.vararr(ctype, array)
  if type(array) == 'table' then
    local vtype = ffi.typeof('$[?]', ffi.typeof(ctype))
    local vsize = #array + 1

    array = ffi.new(vtype, vsize, array)
    -- define the end of the list
    array[vsize - 1] = nil
  end

  return array
end

function help.attrname(name)
  return type(name) == 'string' and name:upper() or name
end

function help.attrvalue(value)
  return type(value) ~= 'cdata' and tostring(value) or value
end

function help.set_attributes_table(ih, t)
  if t == nil then return end

  local i = 1
  for k,v in pairs(t) do
    if k == i then
      i = i + 1
      mod.append(ih, v)
    else
      mod.set_attribute(ih, k, v)
    end
  end
end

function help.strchar(s,i)
  if type(s) == 'string' then
    return string.sub(s, i + 1, i + 1)
  end
  return string.char(s[i])
end


widget_mt = {}
widget_mt.__index = widget_mt

widget_mt.update                = mod.update
widget_mt.update_children       = mod.update_children
widget_mt.redraw                = mod.redraw
widget_mt.refresh               = mod.refresh
widget_mt.refresh_children      = mod.refresh_children

widget_mt.append                = mod.append
widget_mt.insert                = mod.insert
widget_mt.get_child             = mod.get_child
widget_mt.get_child_pos         = mod.get_child_pos
widget_mt.get_child_count       = mod.get_child_count
widget_mt.get_next_child        = mod.get_next_child
widget_mt.get_brother           = mod.get_brother
widget_mt.get_parent            = mod.get_parent
widget_mt.get_dialog            = mod.get_dialog
widget_mt.get_dialog_child      = mod.get_dialog_child

widget_mt.popup                 = mod.popup
widget_mt.show                  = mod.show
widget_mt.show_xy               = mod.show_xy
widget_mt.hide                  = mod.hide
widget_mt.map                   = mod.map
widget_mt.unmap                 = mod.unmap

widget_mt.reset_attribute       = mod.reset_attribute
widget_mt.get_all_attributes    = mod.get_all_attributes
widget_mt.set_attributes        = mod.set_attributes
widget_mt.get_attributes        = mod.get_attributes
widget_mt.set_attribute         = mod.set_attribute
widget_mt.set_str_attribute     = mod.set_str_attribute
widget_mt.set_strf              = mod.set_strf
widget_mt.set_int               = mod.set_int
widget_mt.set_float             = mod.set_float
widget_mt.set_double            = mod.set_double
widget_mt.set_rgb               = mod.set_rgb
widget_mt.get_attribute         = mod.get_attribute
widget_mt.get_int               = mod.get_int
widget_mt.get_int2              = mod.get_int2
widget_mt.get_int_int           = mod.get_int_int
widget_mt.get_float             = mod.get_float
widget_mt.get_double            = mod.get_double
widget_mt.get_rgb               = mod.get_rgb
widget_mt.set_attribute_id      = mod.set_attribute_id
widget_mt.set_str_attribute_id  = mod.set_str_attribute_id
widget_mt.set_strf_id           = mod.set_strf_id
widget_mt.set_int_id            = mod.set_int_id
widget_mt.set_float_id          = mod.set_float_id
widget_mt.set_double_id         = mod.set_double_id
widget_mt.set_rgb_id            = mod.set_rgb_id
widget_mt.get_attribute_id      = mod.get_attribute_id
widget_mt.get_int_id            = mod.get_int_id
widget_mt.get_float_id          = mod.get_float_id
widget_mt.get_double_id         = mod.get_double_id
widget_mt.get_rgb_id            = mod.get_rgb_id
widget_mt.set_attribute_id2     = mod.set_attribute_id2
widget_mt.set_str_attribute_id2 = mod.set_str_attribute_id2
widget_mt.set_strf_id2          = mod.set_strf_id2
widget_mt.set_int_id2           = mod.set_int_id2
widget_mt.set_float_id2         = mod.set_float_id2
widget_mt.set_double_id2        = mod.set_double_id2
widget_mt.set_rgb_id2           = mod.set_rgb_id2
widget_mt.get_attribute_id2     = mod.get_attribute_id2
widget_mt.get_int_id2           = mod.get_int_id2
widget_mt.get_float_id2         = mod.get_float_id2
widget_mt.get_double_id2        = mod.get_double_id2
widget_mt.get_rgb_id2           = mod.get_rgb_id2

widget_mt.previous_field        = mod.previous_field
widget_mt.next_field            = mod.next_field
widget_mt.get_callback          = mod.get_callback
widget_mt.set_callback          = mod.set_callback
widget_mt.set_callbacks         = mod.set_callbacks

widget_mt.get_name              = mod.get_name
widget_mt.set_attribute_handle  = mod.set_attribute_handle
widget_mt.get_attribute_handle  = mod.get_attribute_handle
widget_mt.get_class_name        = mod.get_class_name
widget_mt.get_class_type        = mod.get_class_type

mod.raw = bind

mod.const = const
mod.cb = cb

mod.builder = builder

setmetatable(mod, {
  __call = function(self, name)
    ffi.cdef(header)

    bind = ffi.load(name)

    ffi.metatype('Ihandle', widget_mt)

    for k,v in pairs(cb) do
      cb[k] = type(v) == 'string' and ffi.typeof(v) or v
    end

    return self
  end
})

return mod
