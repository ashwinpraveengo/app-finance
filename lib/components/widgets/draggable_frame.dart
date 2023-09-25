// Copyright 2023 The terCAD team. All rights reserved.
// Use of this source code is governed by a CC BY-NC-ND 4.0 license that can be found in the LICENSE file.

import 'package:app_finance/_classes/herald/app_locale.dart';
import 'package:app_finance/_ext/build_context_ext.dart';
import 'package:app_finance/components/components_builder_form.dart';
import 'package:app_finance/components/components_data.dart';
import 'package:app_finance/components/interface_component.dart';
import 'package:app_finance/components/widgets/draggable_pointer.dart';
import 'package:app_finance/widgets/wrapper/confirmation_wrapper.dart';
import 'package:app_finance/widgets/wrapper/tap_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grid_layout/flutter_grid_layout.dart';

class DraggableFrame extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function delete;
  final Function adjust;

  const DraggableFrame(
    this.data, {
    super.key,
    required this.delete,
    required this.adjust,
  });

  @override
  DraggableFrameState createState() => DraggableFrameState();
}

class DraggableFrameState extends State<DraggableFrame> {
  Color? color;
  bool isDrag = false;
  final _shift = InterfaceComponent.shift;
  final _start = InterfaceComponent.start;
  final _end = InterfaceComponent.end;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final frameLine = MouseRegion(
      cursor: SystemMouseCursors.move,
      onEnter: (_) => setState(() => color = colorScheme.primary.withOpacity(0.5)),
      onExit: (_) => setState(() => color = null),
      child: Container(
        color: color ?? colorScheme.secondary.withOpacity(0.2),
      ),
    );
    onDragStarted() => setState(() => isDrag = true);
    onDragEnd(_) => setState(() => isDrag = false);
    return Draggable<ComponentData>(
      data: {...widget.data, _shift: true},
      onDragStarted: onDragStarted,
      onDragEnd: onDragEnd,
      feedback: Container(color: context.colorScheme.primary, height: 40, width: 60),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: GridContainer(
          columns: const [7, 24, null, 24, 7],
          rows: const [7, 24, null, 24, 7],
          children: [
            GridItem(
                start: const Size(0, 0),
                end: const Size(4, 4),
                child: Visibility(
                  visible: !isDrag,
                  child: ComponentsBuilderForm(widget.data, adjust: widget.adjust),
                )),
            GridItem(
              start: const Size(0, 0),
              end: const Size(5, 1),
              order: 1,
              child: frameLine,
            ),
            GridItem(
              start: const Size(0, 1),
              end: const Size(1, 5),
              order: 1,
              child: frameLine,
            ),
            GridItem(
              start: const Size(4, 1),
              end: const Size(5, 5),
              order: 1,
              child: frameLine,
            ),
            GridItem(
              start: const Size(1, 4),
              end: const Size(4, 5),
              order: 1,
              child: frameLine,
            ),
            GridItem(
              start: const Size(3, 1),
              end: const Size(4, 2),
              order: 1,
              child: Visibility(
                visible: !isDrag,
                child: TapWidget(
                  tooltip: AppLocale.labels.deleteTooltip,
                  onTap: () => ConfirmationWrapper.show(
                    context,
                    () => widget.delete(widget.data[InterfaceComponent.order]),
                  ),
                  child: Icon(
                    Icons.delete,
                    color: context.colorScheme.primary,
                  ),
                ),
              ),
            ),
            GridItem(
              start: const Size(1, 1),
              end: const Size(2, 2),
              order: 2,
              child: DraggablePointer(
                {...widget.data, _start: true},
                onDragStarted: onDragStarted,
                onDragEnd: onDragEnd,
              ),
            ),
            GridItem(
              start: const Size(3, 3),
              end: const Size(4, 4),
              order: 3,
              child: DraggablePointer(
                {...widget.data, _end: true},
                onDragStarted: onDragStarted,
                onDragEnd: onDragEnd,
                topLeft: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}