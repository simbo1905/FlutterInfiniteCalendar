# Demo 01: Meal Planner with Infinite Calendar View

## 1. Calendar Component/Library Used

This demo uses a **custom infinite scrolling calendar** implementation built with Flutter's native widgets:

- **CustomScrollView + SliverList** for infinite vertical scrolling
- **ReorderableListView** for horizontal meal card reordering within days
- **DragTarget and LongPressDraggable** for inter-day drag-and-drop functionality
- **flutter_riverpod** (v2.5.1) for state management

The implementation follows the same infinite scrolling pattern as `infinite_calendar_demo`, adapted specifically for the meal planning use case defined in SPEC.md.

## 2. What Was Not Possible from the Spec

All core requirements from SPEC.md have been successfully implemented:

✅ **Infinite scrolling calendar** - Vertical scroll with dynamic week loading
✅ **Meal card management** - Add, delete, reorder, and move meals
✅ **Drag-and-drop** - Both intra-day (horizontal) and inter-day (vertical) movement
✅ **Save/Reset functionality** - Dual state management (working vs persistent)
✅ **Day selection** - Visual highlighting of selected day
✅ **Mock data** - All 10 meal templates from SPEC Table 5
✅ **Bottom sheet** - Add meal interface with template selection
✅ **Delete confirmation** - Dialog before removing meals
✅ **Week grouping** - Week headers with date ranges and week numbers
✅ **Current day highlighting** - Visual distinction for today's date

### Minor Implementation Notes:

1. **Auto-scroll during drag**: The viewport auto-scroll when dragging near edges is handled by Flutter's built-in DragTarget behavior. A more sophisticated implementation could enhance this with programmatic scrolling.

2. **Icon mapping**: Some SPEC icon names (e.g., "bowl", "nutrition") were mapped to the closest Material Icons equivalents (e.g., `breakfast_dining`, `apple`).

3. **Color gradients**: Meal card color tabs use a subtle vertical gradient for visual polish, as suggested in the spec.

## Running the Demo

```bash
cd demo/01
flutter pub get
flutter run -d chrome  # For web
flutter run            # For mobile
```
