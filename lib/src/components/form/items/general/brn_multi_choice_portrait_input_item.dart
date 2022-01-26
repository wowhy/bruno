import 'package:bruno/src/components/form/base/brn_form_item_type.dart';
import 'package:bruno/src/components/form/base/input_item_interface.dart';
import 'package:bruno/src/components/form/utils/brn_form_util.dart';
import 'package:bruno/src/components/line/brn_line.dart';
import 'package:bruno/src/components/radio/brn_checkbox.dart';
import 'package:bruno/src/components/radio/brn_radio_core.dart';
import 'package:bruno/src/theme/brn_theme_configurator.dart';
import 'package:bruno/src/theme/configs/brn_form_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///
/// 纵向多选录入项
///
/// 包括"标题"、"副标题"、"错误信息提示"、"必填项提示"、"添加/删除按钮"、"消息提示"、
/// "多选项"等元素
///
// ignore: must_be_immutable
class BrnMultiChoicePortraitInputFormItem extends StatefulWidget {
  /// 录入项的唯一标识，主要用于录入类型页面框架中
  final String label;

  /// 录入项类型，主要用于录入类型页面框架中
  String type = BrnInputItemType.MULTI_CHOICE_PORTRAIT_INPUT_TYPE;

  /// 录入项标题
  final String title;

  /// 录入项子标题
  final String subTitle;

  /// 录入项提示（问号图标&文案） 用户点击时触发onTip回调。
  /// 1. 若赋值为 空字符串（""）时仅展示"问号"图标，
  /// 2. 若赋值为非空字符串时 展示"问号图标&文案"，
  /// 3. 若不赋值或赋值为null时 不显示提示项
  /// 默认值为 3
  final String tipLabel;

  /// 录入项前缀图标样式 "添加项" "删除项" 详见 PrefixIconType类
  final String prefixIconType;

  /// 录入项错误提示
  final String error;

  /// 录入项是否为必填项（展示*图标） 默认为 false 不必填
  final bool isRequire;

  /// 录入项 是否可编辑
  final bool isEdit;

  /// 点击"+"图标回调
  final VoidCallback onAddTap;

  /// 点击"-"图标回调
  final VoidCallback onRemoveTap;

  /// 点击"？"图标回调
  final VoidCallback onTip;

  /// 特殊字段
  List<String> value;

  /// 内容
  List<String> options;

  /// 局部禁用list
  List<bool> enableList;

  /// 选项选中状态变化回调
  final OnBrnFormMultiChoiceValueChanged onChanged;

  /// form配置
  BrnFormItemConfig themeData;

  BrnMultiChoicePortraitInputFormItem(
      {Key key,
      this.label,
      this.title: "",
      this.subTitle,
      this.tipLabel,
      this.prefixIconType: BrnPrefixIconType.TYPE_NORMAL,
      this.error: "",
      this.isEdit: true,
      this.isRequire: false,
      this.onAddTap,
      this.onRemoveTap,
      this.onTip,
      this.value,
      this.options,
      this.enableList,
      this.onChanged,
      this.themeData})
      : super() {
    this.themeData ??= BrnFormItemConfig();
    this.themeData = BrnThemeConfigurator.instance
        .getConfig(configId: this.themeData.configId)
        .formItemConfig
        .merge(this.themeData);
  }

  @override
  BrnMultiChoicePortraitInputFormItemState createState() {
    return BrnMultiChoicePortraitInputFormItemState();
  }
}

class BrnMultiChoicePortraitInputFormItemState
    extends State<BrnMultiChoicePortraitInputFormItem> {
  // 标记选项的选中状态，内部变量无须初始化。初始化选中状态通过设置value字段设置
  List<bool> _selectStatus;

  @override
  void initState() {
    _initSpecialParams();
    _initSelectedStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: BrnFormUtil.itemEdgeInsets(widget.themeData),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 25,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: BrnFormUtil.titleEdgeInsets(widget.prefixIconType,
                      widget.isRequire, widget.themeData),
                  child: Row(
                    children: <Widget>[
                      BrnFormUtil.buildPrefixIcon(
                          widget.prefixIconType,
                          widget.isEdit,
                          context,
                          widget.onAddTap,
                          widget.onRemoveTap),
                      BrnFormUtil.buildRequireWidget(widget.isRequire),
                      BrnFormUtil.buildTitleWidget(
                          widget.title, widget.themeData),
                      BrnFormUtil.buildTipLabelWidget(
                          widget.tipLabel, widget.onTip, widget.themeData),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 副标题
          BrnFormUtil.buildSubTitleWidget(widget.subTitle, widget.themeData),

          BrnFormUtil.buildErrorWidget(widget.error, widget.themeData),

          Container(
            padding: EdgeInsets.only(left: 20, top: 14),
            child: Column(
              children: getCheckboxList(widget.options),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> getCheckboxList(List<String> options) {
    List<Widget> result = List();
    if (options == null || options.isEmpty) {
      result.add(Container());
      return result;
    }

    result.add(BrnLine(leftInset: 20, rightInset: 20));

    for (int index = 0; index < options.length; ++index) {
      result.add(Container(
        padding: EdgeInsets.only(top: 11, bottom: 11),
        child: BrnCheckbox(
          key: GlobalKey(),
          child: Text(options[index], style: getOptionTextStyle(index)),
          childOnRight: false,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          radioIndex: index,
          disable: getRadioEnableState(index),
          isSelected: (_selectStatus != null && index < _selectStatus.length)
              ? _selectStatus[index]
              : false,
          onValueChangedAtIndex: (position, value) {
            _selectStatus[position] = value;
            List<String> oldValue = List<String>()..addAll(widget.value);

            setState(() {
              widget.value.clear();

              for (int i = 0; i < _selectStatus.length; ++i) {
                if (_selectStatus[i]) {
                  widget.value.add(widget.options[i]);
                }
              }
              BrnFormUtil.notifyMultiChoiceStatusChanged(
                  widget.onChanged, context, oldValue, widget.value);
            });
          },
        ),
      ));

      result.add(BrnLine(leftInset: 20, rightInset: 20));
    }

    return result;
  }

  TextStyle getOptionTextStyle(int index) {
    TextStyle result = BrnFormUtil.getOptionTextStyle(widget.themeData);
    if (index < 0 || index >= _selectStatus.length) {
      return result;
    }

    if (_selectStatus[index]) {
      result = BrnFormUtil.getOptionSelectedTextStyle(widget.themeData);
    }

    if (widget.isEdit != null && !widget.isEdit) {
      result = BrnFormUtil.getIsEditTextStyle(widget.themeData, widget.isEdit);
    }

    if (widget.enableList != null &&
        widget.enableList.isNotEmpty &&
        widget.enableList.length > index &&
        !widget.enableList[index]) {
      result = BrnFormUtil.getIsEditTextStyle(widget.themeData, false);
    }

    return result;
  }

  bool getRadioEnableState(int index) {
    if (widget.isEdit != null && !widget.isEdit) {
      return true;
    }

    if (widget.enableList == null ||
        widget.enableList.isEmpty ||
        widget.enableList.length < index) {
      return false;
    }

    return !widget.enableList[index];
  }

  void _initSpecialParams() {
    if (widget.value == null) {
      widget.value = List<String>();
    }

    if (widget.options == null) {
      widget.options = List<String>();
    }

    if (widget.enableList == null) {
      widget.enableList = List<bool>();
    }
  }

  void _initSelectedStatus() {
    if (widget.options != null && widget.options.isNotEmpty) {
      _selectStatus = List<bool>(widget.options.length);
    } else {
      _selectStatus = List<bool>();
    }

    for (int index = 0; index < _selectStatus.length; ++index) {
      _selectStatus[index] = false;
    }

    if (widget.value == null || widget.value.isEmpty) {
      return;
    }

    for (int index = 0; index < widget.value.length; ++index) {
      int pos = widget.options.indexOf(widget.value[index]);

      if (pos < 0) {
        return;
      }
      _selectStatus[pos] = true;
    }
  }
}