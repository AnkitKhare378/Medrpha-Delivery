import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../models/OrderM/store_holiday_model.dart';
import '../../../../../models/OrderM/store_shift_model.dart';
import '../../../../../view_models/OrderVM/store_shift_view_model.dart';
import 'slot_card_shimmer.dart';

class SlotCard extends StatefulWidget {
  final int storeId;
  final bool? forOrder; // New parameter to handle UI variations
  final Function(bool isEmpty)? onAvailabilityChanged;
  final Function(String formattedTime)? onTimeSelected;
  final Function(String formattedDate)? onDateSelected;

  const SlotCard({
    super.key,
    required this.storeId,
    this.forOrder = false, // Defaults to false for Cart UI
    this.onAvailabilityChanged,
    this.onTimeSelected,
    this.onDateSelected,
  });

  @override
  State<SlotCard> createState() => _SlotCardState();
}

class _SlotCardState extends State<SlotCard> {
  String? _selectedSlot;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<StoreShiftBloc>().add(FetchStoreShifts(widget.storeId));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onDateSelected?.call(_selectedDate.toIso8601String());
    });
  }

  StoreHolidayModel? _checkHoliday(List<StoreHolidayModel> holidays) {
    for (var holiday in holidays) {
      try {
        DateTime holidayStart = DateTime.parse(holiday.startDate);
        DateTime holidayEnd = DateTime.parse(holiday.endDate);

        DateTime selectedDateOnly = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
        DateTime startOnly = DateTime(holidayStart.year, holidayStart.month, holidayStart.day);
        DateTime endOnly = DateTime(holidayEnd.year, holidayEnd.month, holidayEnd.day);

        if (selectedDateOnly.isAtSameMomentAs(startOnly) ||
            (selectedDateOnly.isAfter(startOnly) && selectedDateOnly.isBefore(endOnly)) ||
            selectedDateOnly.isAtSameMomentAs(endOnly)) {
          return holiday;
        }
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  List<String> _generateSlots(StoreShiftModel shift) {
    List<String> slots = [];
    try {
      final startParts = shift.openTime.split(':');
      final endParts = shift.closeTime.split(':');

      int startHr = int.parse(startParts[0]);
      int endHr = int.parse(endParts[0]);
      int endMin = int.parse(endParts[1]);

      if (startHr == endHr && endMin == 0) return [];

      for (int i = startHr; i <= endHr; i++) {
        if (i == endHr && endMin == 0) continue;
        slots.add("${i.toString().padLeft(2, '0')}:00");
      }
    } catch (e) {
      return [];
    }
    return slots;
  }

  List<String> _getFilteredSlots(List<String> rawSlots) {
    final now = DateTime.now();
    bool isToday = _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;

    if (!isToday) return rawSlots;

    return rawSlots.where((slot) {
      int slotHour = int.parse(slot.split(':')[0]);
      return slotHour > now.hour;
    }).toList();
  }

  String _formatTo12Hr(String slot24) {
    final hr = int.parse(slot24.split(':')[0]);
    final period = hr >= 12 ? "PM" : "AM";
    final displayHr = hr > 12 ? hr - 12 : (hr == 0 ? 12 : hr);
    return "${displayHr.toString().padLeft(2, '0')}:00 $period";
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 14)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedSlot = null;
      });
      // Notify parent of the new date selection
      widget.onDateSelected?.call(_selectedDate.toIso8601String());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreShiftBloc, StoreShiftState>(
      builder: (context, state) {
        if (state is StoreShiftLoading) {
          return const SlotCardShimmer();
        }
        if (state is StoreShiftError) {
          return Center(child: Padding(padding: const EdgeInsets.all(10), child: Text("Error: ${state.message}")));
        }
        if (state is StoreShiftLoaded) {
          final holiday = _checkHoliday(state.holidays);
          final int selectedDayOfWeek = _selectedDate.weekday;

          final dayShift = state.shifts.firstWhere(
                (s) => s.dayOfWeek == selectedDayOfWeek,
            orElse: () => StoreShiftModel(
                shiftId: 0, storeId: 0, dayOfWeek: selectedDayOfWeek,
                openTime: "00:00:00", closeTime: "00:00:00", is24Hours: false),
          );

          final availableSlots = _getFilteredSlots(_generateSlots(dayShift));
          bool isCurrentlyEmpty = holiday != null || availableSlots.isEmpty;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onAvailabilityChanged?.call(isCurrentlyEmpty);
          });

          // Core UI Content
          Widget mainBody = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDatePickerTrigger(),
              const SizedBox(height: 20),
              if (holiday != null)
                _buildHolidayBox(holiday.holidayName)
              else ...[
                _buildHeader(availableSlots),
                const SizedBox(height: 12),
                if (availableSlots.isEmpty)
                  _buildNoSlotsState()
                else
                  _buildSlotsGrid(availableSlots),
              ],
            ],
          );

          // Conditional wrapper based on forOrder parameter
          if (widget.forOrder == true) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: mainBody,
            );
          }

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: mainBody,
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildDatePickerTrigger() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50.withOpacity(0.4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: Colors.blue.shade700, size: 18),
            const SizedBox(width: 12),
            Text(
              DateFormat('EEEE, dd MMM').format(_selectedDate),
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.blue.shade900),
            ),
            const Spacer(),
            Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.blue.shade700),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(List<String> availableSlots) {
    return Row(
      children: [
        Text(
          'Select Time',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const Spacer(),
        if (availableSlots.isNotEmpty)
          Text(
            _selectedSlot != null ? _formatTo12Hr(_selectedSlot!) : "Choose a slot",
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
          ),
      ],
    );
  }

  Widget _buildSlotsGrid(List<String> availableSlots) {
    return RepaintBoundary(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: availableSlots.map((slot) {
          final isSelected = slot == _selectedSlot;
          return _buildSlotButton(slot, isSelected);
        }).toList(),
      ),
    );
  }

  Widget _buildNoSlotsState() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "No available slots for the selected day.",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.red.shade900, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHolidayBox(String holidayName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy, color: Colors.orange.shade700, size: 30),
          const SizedBox(height: 8),
          Text(
            "Lab Closed: $holidayName",
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.orange.shade900),
          ),
          Text(
            "Please pick a different date.",
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange.shade800),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotButton(String slot, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() => _selectedSlot = slot);
        widget.onTimeSelected?.call("$slot:00");
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
            width: 1.5,
          ),
          color: isSelected ? Colors.blue.shade700 : Colors.white,
        ),
        child: Text(
          _formatTo12Hr(slot),
          style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}