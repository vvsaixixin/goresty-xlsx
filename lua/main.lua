local ffi = require("ffi")

--  Load shex fii lib
local shex = ffi.load("shex")
ffi.cdef[[
typedef struct { const char *p; ptrdiff_t n; } _GoString_;
typedef char _check_for_64_bit_pointer_matching_GoInt[sizeof(void*)==64/8 ? 1:-1];
typedef signed char GoInt8;
typedef unsigned char GoUint8;
typedef short GoInt16;
typedef unsigned short GoUint16;
typedef int GoInt32;
typedef unsigned int GoUint32;
typedef long long GoInt64;
typedef unsigned long long GoUint64;
typedef GoInt64 GoInt;
typedef GoUint64 GoUint;
typedef float GoFloat32;
typedef double GoFloat64;
typedef float _Complex GoComplex64;
typedef double _Complex GoComplex128;
typedef void *GoMap;
typedef void *GoChan;
typedef struct { void *t; void *v; } GoInterface;
typedef struct { void *data; GoInt len; GoInt cap; } GoSlice;
typedef _GoString_ GoString;
extern GoInt sum(GoInt a, GoInt b);
extern void println(GoString str);
extern GoInt createExcelFile(GoString filename);
extern void cell(GoInt resourceId, GoString tabIndex, GoString val);
extern void selectSheet(GoInt resourceId, GoString sheet);
extern void merge(GoInt resourceId, GoString si, GoString ei);
extern void save(GoInt resourceId);
extern GoInt registerStyle(GoInt resourceId, GoString style);
extern void setCellStyle(GoInt resourceId, GoString cellX, GoString cellY, GoInt styleId);
]]

Excel = {
    resourceId = 0,
    filename  = ""
}

-- Golang String 
function GoString(s) 
    local gstr = ffi.new("GoString")

    gstr.p = s
    gstr.n = #s

    return gstr
end



--  创建一个 Excel 文件
function Excel:new(filename) 
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.filename = filename
    self.resourceId = shex.createExcelFile(GoString(filename))
    return o
end 

--  选择一个工作表 默认为工作表名为 sheet1
function Excel:sel(sheet) 
    shex.selectSheet(self.resourceId ,GoString(sheet))
    return o
end

--  向工作区域中填充数据
function Excel:cell(index ,value) 
    shex.cell(
        self.resourceId ,
        GoString(index), 
        GoString(value)
    )
    return o
end

function Excel:merge(si ,ei) 
    shex.merge(self.resourceId,GoString(si),GoString(ei))
    return o
end

--  保存数据表
function Excel:save() 
    shex.save(self.resourceId)
end

--  注册Excel表样式
--  样式表请查阅这里 https://xuri.me/excelize/zh-hans/style.html 
function Excel:registerStyle(style) 
    return shex.registerStyle(
        self.resourceId,
        GoString(style)
    )
end 

--  设置单元格样式
function Excel:setCellStyle(cellIndexX ,cellIndexY,styleId)
    shex.setCellStyle(
        self.resourceId, 
        GoString(cellIndexX),
        GoString(cellIndexY),
        tonumber(styleId)
    )
end


local table1 = Excel:new("表格1.xlsx")

--  预设单元格样式1
-- 蓝低无边框样式
local style1 = table1:registerStyle("{\"fill\":{\"type\":\"pattern\",\"color\":[\"#E0EBF5\"],\"pattern\":1}}")

-- 黑底无边框样式
local style2 = table1:registerStyle("{\"fill\":{\"type\":\"pattern\",\"color\":[\"#000000\"],\"pattern\":1}}")

--  将 A1-E10 区域设置为 Style1 的样式，即蓝底无线框样式
table1:setCellStyle("A1","E10",style1)

--  将 A5-B6 区域设置为 Style1 的样式，即黑底无线框样式
table1:setCellStyle("A5","B6",style2)

table1:cell("A3","H-1")
table1:sel("Sheet2")
table1:cell("B2","你好")
table1:sel("Sheet1")
table1:merge("A1","A3")
table1:cell("A3","H-2")
table1:save()