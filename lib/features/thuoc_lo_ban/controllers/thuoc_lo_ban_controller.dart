import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/ruler_model.dart';
import '../data/ruler_data.dart';
import '../utils/ruler_calculator.dart';
// Removed haptic helper import - haptic feedback disabled

enum Unit { mm, inch }

class ThuocLoBanController extends GetxController with GetSingleTickerProviderStateMixin {
  // Current state
  final _currentInput = 75.0.obs; // Default 75mm (7.5cm) - always in mm internally
  final _selectedUnit = Unit.mm.obs; // Default to mm
  final _selectedRulerType = RulerType.thongThuy.obs;
  final _results = <RulerResult>[].obs;
  final _isLoading = false.obs;
  
  // Scroll controller
  late ScrollController scrollController;
  
  // Input controller
  late TextEditingController inputController;
  
  // Rulers data
  late Map<RulerType, RulerModel> rulers;
  
  // Simple performance flags (used in screen for state management)
  bool _isDragging = false;
  
  // Smart text field update throttling
  DateTime? _lastTextFieldUpdate;
  static const _textFieldThrottleMs = 16; // 16ms = 60fps for smoother updates
  
  // Animation controller for smooth momentum
  late AnimationController _momentumController;
  Animation<double>? _momentumAnimation;
  
  // Getters
  double get currentInput => _currentInput.value; // Always in mm internally
  Unit get selectedUnit => _selectedUnit.value;
  RulerType get selectedRulerType => _selectedRulerType.value;
  List<RulerResult> get results => _results;
  bool get isLoading => _isLoading.value;
  RulerModel get currentRuler => rulers[selectedRulerType]!;
  
  String get currentInputCm => (currentInput / 10).toStringAsFixed(1);
  
  // Unit conversion constants
  static const double mmPerInch = 25.4;
  
  // Convert mm to inch
  double mmToInch(double mm) => mm / mmPerInch;
  
  // Convert inch to mm  
  double inchToMm(double inch) => inch * mmPerInch;
  
  // Get display value based on selected unit
  double get displayValue {
    return selectedUnit == Unit.mm ? currentInput : mmToInch(currentInput);
  }
  
  // Get display value as string
  String get displayValueString {
    final value = displayValue;
    
    // Hiển thị số đầy đủ, không dùng scientific notation
    if (selectedUnit == Unit.mm) {
      // Hiển thị 1 số thập phân cho mm để tránh giật khi scroll
      // Nếu là số nguyên (10.0) thì hiển thị "10", nếu có phần lẻ (10.3) thì hiển thị "10.3"
      return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);
    } else {
      // Inch luôn hiển thị 2 số thập phân
      return value.toStringAsFixed(2);
    }
  }
  
  // Get unit label
  String get unitLabel => selectedUnit == Unit.mm ? 'mm' : 'inch';
  
  // Validation - observable
  final _inputError = Rxn<String>();
  String? get inputError => _inputError.value;
  
  void _updateInputError() {
    if (inputController.text.isEmpty) {
      _inputError.value = null;
    } else {
      _inputError.value = RulerCalculator.validateInput(inputController.text);
    }
  }
  
  bool get hasResults => results.isNotEmpty;
  bool get isDragging => _isDragging;
  
  @override
  void onInit() {
    super.onInit();
    
    // Haptic feedback disabled - removed initialization
    
    rulers = RulerData.getAllRulers();
    
    _momentumController = AnimationController(
      duration: const Duration(milliseconds: 600), // Default duration, will be dynamic
      vsync: this,
    );
    
    scrollController = ScrollController();
    inputController = TextEditingController(text: displayValueString);
    
    _calculateResults();
    _setupInputListener();
  }
  
  @override
  void onClose() {
    _momentumController.dispose();
    scrollController.dispose();
    inputController.dispose();
    super.onClose();
  }
  
  void _setupInputListener() {
    // Debounced input listener
    inputController.addListener(() {
      _debounceInput();
    });
  }
  
  Timer? _debounceTimer;
  void _debounceInput() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 150), () { // Reduced to 150ms for snappier response
      _onInputChanged();
    });
  }
  
  void _onInputChanged() {
    final text = inputController.text.trim();
    _updateInputError(); // Update validation
    
    if (text.isEmpty) return;
    
    final value = double.tryParse(text);
    if (value == null) return;
    
    // Convert input to mm (internal storage)
    final valueInMm = selectedUnit == Unit.mm ? value : inchToMm(value);
    
    if (RulerCalculator.isValidInput(valueInMm)) {
      updateInput(valueInMm, updateTextField: false);
    }
  }
  
  void updateInput(double newInput, {bool updateTextField = true, bool smooth = true}) {
    // Validate input
    if (newInput.isNaN || newInput.isInfinite) return;
    
    // Only clamp negative values, no upper limit for scroll/drag
    final clampedInput = newInput < 0 ? 0.0 : newInput;
    if (clampedInput == currentInput) return;
    
    // Stop any running animations during drag
    if (_isDragging) {
      _momentumController.stop();
    }
    
    _currentInput.value = clampedInput;
    
    if (updateTextField) {
      inputController.text = displayValueString;
    }
    
    _calculateResults();
    
    // Smart update strategy
    if (_isDragging) {
      final now = DateTime.now();
      final lastUpdate = _lastTextFieldUpdate;
      final shouldUpdateTextField = lastUpdate == null || 
          (now.millisecondsSinceEpoch - lastUpdate.millisecondsSinceEpoch) >= _textFieldThrottleMs;
      
      if (shouldUpdateTextField) {
        _lastTextFieldUpdate = now;
        if (updateTextField) {
          inputController.text = displayValueString;
        }
        update(['ruler-canvas', 'input-field', 'bottom-info']);
      } else {
        update(['ruler-canvas', 'bottom-info']);
      }
    } else {
      update(['ruler-canvas', 'input-field', 'bottom-info']);
    }
    
    if (smooth && !_isDragging) {
      _scrollToPosition(smooth: true);
    }
  }
  
  void updateRulerType(RulerType newType) {
    if (newType == selectedRulerType) return;
    
    _selectedRulerType.value = newType;
    _calculateResults();
    update(['ruler-canvas', 'bottom-info']); // Update bottom info when ruler type changes
  }
  
  void updateUnit(Unit newUnit) {
    if (newUnit == selectedUnit) return;
    
    _selectedUnit.value = newUnit;
    inputController.text = displayValueString;
    update(['ruler-canvas', 'input-field', 'unit-selector']);
  }
  
  void _calculateResults() {
    _isLoading.value = true;
    
    try {
      if (rulers.isEmpty) {
        _results.clear();
        return;
      }
      
      final newResults = RulerCalculator.calculateForAllRulers(rulers, currentInput);
      _results.assignAll(newResults);
    } catch (e) {
      _results.clear();
    } finally {
      _isLoading.value = false;
    }
  }
  
  void onInputSubmitted() {
    final text = inputController.text.trim();
    if (text.isEmpty) {
      // When empty, set to 0
      updateInput(0.0, updateTextField: true);
      _inputError.value = null;
      return;
    }
    
    final value = double.tryParse(text);
    if (value == null) {
      _inputError.value = 'Vui lòng nhập số hợp lệ';
      return;
    }
    
    final valueInMm = selectedUnit == Unit.mm ? value : inchToMm(value);
    final validation = RulerCalculator.validateInput(valueInMm.toString());
    if (validation != null) {
      _inputError.value = validation;
      // Removed haptic feedback for validation error
      return;
    }
    
    _inputError.value = null;
    // Use smart animation instead of direct update
    smartJumpToInput(valueInMm);
    // Removed haptic feedback for successful input
  }
  
  void onInputUnfocused() {
    final text = inputController.text.trim();
    if (text.isEmpty) {
      // When unfocused and empty, set to 0
      updateInput(0.0, updateTextField: true);
      _inputError.value = null;
    }
  }
  
  void onScroll() {
    if (scrollController.hasClients) {
      final newMm = RulerCalculator.calculateMmFromScroll(
        scrollController.offset, 
        Get.width
      );
      
      if ((newMm - currentInput).abs() > 1) { // Only update if significant change
        _currentInput.value = newMm;
        // Use displayValueString instead of toInt() to support decimal values
        updateInput(newMm, updateTextField: true);
      }
    }
  }
  
  void _scrollToPosition({bool smooth = true}) {
    if (!scrollController.hasClients) return;
    
    final targetPosition = RulerCalculator.calculateScrollPosition(
      currentInput, 
      Get.width
    );
    
    if (smooth) {
      scrollController.animateTo(
        targetPosition,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      scrollController.jumpTo(targetPosition);
    }
  }
  
  // Get result for specific ruler type
  RulerResult? getResultForRuler(RulerType type) {
    try {
      return results.firstWhere((r) => r.ruler.type == type);
    } catch (e) {
      return null;
    }
  }
  
  // Get current selected ruler result
  RulerResult? get currentResult => getResultForRuler(selectedRulerType);
  
  // Reset to default
  void reset() {
    updateInput(75.0);
    _selectedRulerType.value = RulerType.thongThuy;
  }
  
  // Format helpers
  String formatMmToCm(double mm) {
    return (mm / 10).toStringAsFixed(1);
  }
  
  Color getKhoangColor(RulerResult result) {
    return result.isGood ? Colors.green : Colors.red;
  }
  
  IconData getKhoangIcon(RulerResult result) {
    return result.isGood ? Icons.check_circle : Icons.warning;
  }
  
  // Removed complex viewport management methods
  
  void startDrag() {
    _isDragging = true;
    _momentumController.stop();
    _lastTextFieldUpdate = null;
  }
  
  void endDrag() {
    _isDragging = false;
    inputController.text = displayValueString;
  }
  
  // Set momentum duration dynamically
  void setMomentumDuration(int milliseconds) {
    _momentumController.duration = Duration(milliseconds: milliseconds);
  }
  
  // Smart jump with animation based on distance
  void smartJumpToInput(double targetMm) {
    final distance = (targetMm - currentInput).abs();
    Duration duration;
    Curve curve;
    
    if (distance < 500) {
      // Short distance: smooth and quick
      duration = const Duration(milliseconds: 300);
      curve = Curves.easeOutCubic;
    } else if (distance < 2000) {
      // Medium distance: balanced speed
      duration = const Duration(milliseconds: 500);
      curve = Curves.easeOutQuart;
    } else if (distance < 10000) {
      // Long distance: fast with visual feedback
      duration = const Duration(milliseconds: 700);
      curve = Curves.fastOutSlowIn;
    } else {
      // Very long distance: instant jump with fade effect
      duration = const Duration(milliseconds: 200);
      curve = Curves.easeInOut;
    }
    
    // Stop any existing animation
    _momentumController.stop();
    
    // Configure animation controller with new duration
    _momentumController.duration = duration;
    
    // Start the animation
    _startAnimatedScroll(targetMm, curve);
  }
  
  void startMomentumScroll(double targetMm) {
    if (targetMm == currentInput) return;
    
    final startMm = currentInput;
    
    _momentumAnimation = Tween<double>(
      begin: startMm,
      end: targetMm,
    ).animate(CurvedAnimation(
      parent: _momentumController,
      curve: Curves.decelerate,
    ));
    
    _momentumAnimation!.addListener(() {
      if (!_isDragging) {
        final animatedValue = _momentumAnimation!.value;
        
        _currentInput.value = animatedValue;
        _calculateResults();
        
        final now = DateTime.now();
        final lastUpdate = _lastTextFieldUpdate;
        
        if (lastUpdate == null || (now.millisecondsSinceEpoch - lastUpdate.millisecondsSinceEpoch) >= _textFieldThrottleMs) {
          _lastTextFieldUpdate = now;
          inputController.text = displayValueString;
          update(['ruler-canvas', 'input-field', 'bottom-info']);
        } else {
          update(['ruler-canvas', 'bottom-info']);
        }
      }
    });
    
    _momentumController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _currentInput.value = targetMm;
        inputController.text = displayValueString;
        update(['ruler-canvas', 'input-field', 'bottom-info']); // Update bottom info when momentum completes
        // Removed haptic feedback when momentum scroll completes
        _momentumController.removeStatusListener((status) {});
      }
    });
    
    _momentumController.reset();
    _momentumController.forward();
  }
  
  // Helper method for animated scrolling
  void _startAnimatedScroll(double targetMm, Curve curve) {
    final startMm = currentInput;
    
    _momentumAnimation = Tween<double>(
      begin: startMm,
      end: targetMm,
    ).animate(CurvedAnimation(
      parent: _momentumController,
      curve: curve,
    ));
    
    _momentumAnimation!.addListener(() {
      if (!_isDragging) {
        final animatedValue = _momentumAnimation!.value;
        
        _currentInput.value = animatedValue;
        _calculateResults();
        inputController.text = displayValueString;
        update(['ruler-canvas', 'input-field', 'bottom-info']);
      }
    });
    
    _momentumController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _currentInput.value = targetMm;
        inputController.text = displayValueString;
        update(['ruler-canvas', 'input-field', 'bottom-info']);
        // Removed haptic feedback
        _momentumController.removeStatusListener((status) {});
      }
    });
    
    _momentumController.reset();
    _momentumController.forward();
  }
}