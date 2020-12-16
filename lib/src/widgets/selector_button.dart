import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/src/models/country_model.dart';
import 'package:intl_phone_number_input/src/utils/selector_config.dart';
import 'package:intl_phone_number_input/src/utils/test/test_helper.dart';
import 'package:intl_phone_number_input/src/widgets/countries_search_list_widget.dart';
import 'package:intl_phone_number_input/src/widgets/input_widget.dart';
import 'package:intl_phone_number_input/src/widgets/item.dart';

class SelectorButton extends StatefulWidget {
  final List<Country> countries;
  final Country country;
  final SelectorConfig selectorConfig;
  final TextStyle selectorTextStyle;
  final InputDecoration searchBoxDecoration;
  final bool autoFocusSearchField;
  final String locale;
  final bool isEnabled;
  final bool isScrollControlled;
  final double width;

  final ValueChanged<Country> onCountryChanged;
  final FocusNode fn = FocusNode();

  SelectorButton({
    Key key,
    @required this.countries,
    @required this.country,
    @required this.selectorConfig,
    @required this.selectorTextStyle,
    @required this.searchBoxDecoration,
    @required this.autoFocusSearchField,
    @required this.locale,
    @required this.onCountryChanged,
    @required this.isEnabled,
    @required this.isScrollControlled,
    this.width,
  });

  @override
  _SelectorButtonState createState() => _SelectorButtonState();
}

class _SelectorButtonState extends State<SelectorButton> {
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    widget.fn.addListener(() {
      setState(() {
        isOpen = widget.fn.hasFocus;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.selectorConfig.selectorType == PhoneInputSelectorType.DROPDOWN
        ? widget.countries.isNotEmpty && widget.countries.length > 1
            ? SizedBox(
                width: widget.width,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Country>(
                    focusNode: widget.fn,
                    key: Key(TestHelper.DropdownButtonKeyValue),
                    hint: Item(
                      country: widget.country,
                      showFlag: widget.selectorConfig.showFlags,
                      useEmoji: widget.selectorConfig.useEmoji,
                      textStyle: widget.selectorTextStyle,
                      showText: false,
                    ),
                    value: widget.country,
                    items: mapCountryToDropdownItem(widget.countries),
                    onChanged: widget.isEnabled ? widget.onCountryChanged : null,
                  ),
                ),
              )
            : Item(
                country: widget.country,
                showFlag: widget.selectorConfig.showFlags,
                useEmoji: widget.selectorConfig.useEmoji,
                textStyle: widget.selectorTextStyle,
                showText: false,
              )
        : MaterialButton(
            key: Key(TestHelper.DropdownButtonKeyValue),
            padding: EdgeInsets.zero,
            minWidth: 0,
            onPressed: widget.countries.isNotEmpty && widget.countries.length > 1
                ? () async {
                    Country selected;
                    if (widget.selectorConfig.selectorType ==
                        PhoneInputSelectorType.BOTTOM_SHEET) {
                      selected = await showCountrySelectorBottomSheet(
                          context, widget.countries);
                    } else {
                      selected =
                          await showCountrySelectorDialog(context, widget.countries);
                    }

                    if (selected != null) {
                      widget.onCountryChanged(selected);
                    }
                  }
                : null,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Item(
                country: widget.country,
                showFlag: widget.selectorConfig.showFlags,
                useEmoji: widget.selectorConfig.useEmoji,
                textStyle: widget.selectorTextStyle,
              ),
            ),
          );
  }

  List<DropdownMenuItem<Country>> mapCountryToDropdownItem(
      List<Country> countries) {
    return countries.map((c) {
      return DropdownMenuItem<Country>(
        value: c,
        child: Item(
          key: Key(TestHelper.countryItemKeyValue(c.alpha2Code)),
          country: c,
          showFlag: widget.selectorConfig.showFlags,
          useEmoji: widget.selectorConfig.useEmoji,
          textStyle: widget.selectorTextStyle,
          withCountryNames: false,
          showText: isOpen
        ),
      );
    }).toList();
  }

  Future<Country> showCountrySelectorDialog(
      BuildContext context, List<Country> countries) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => AlertDialog(
        content: Container(
          width: double.maxFinite,
          child: CountrySearchListWidget(
            countries,
            widget.locale,
            searchBoxDecoration: widget.searchBoxDecoration,
            showFlags: widget.selectorConfig.showFlags,
            useEmoji: widget.selectorConfig.useEmoji,
            autoFocus: widget.autoFocusSearchField,
          ),
        ),
      ),
    );
  }

  Future<Country> showCountrySelectorBottomSheet(
      BuildContext context, List<Country> countries) {
    return showModalBottomSheet(
      context: context,
      clipBehavior: Clip.hardEdge,
      isScrollControlled: widget.isScrollControlled ?? true,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12))),
      builder: (BuildContext context) {
        return AnimatedPadding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          duration: const Duration(milliseconds: 100),
          child: DraggableScrollableSheet(
            builder: (BuildContext context, ScrollController controller) {
              return Container(
                decoration: ShapeDecoration(
                  color: widget.selectorConfig.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                ),
                child: CountrySearchListWidget(
                  countries,
                  widget.locale,
                  searchBoxDecoration: widget.searchBoxDecoration,
                  scrollController: controller,
                  showFlags: widget.selectorConfig.showFlags,
                  useEmoji: widget.selectorConfig.useEmoji,
                  autoFocus: widget.autoFocusSearchField,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
