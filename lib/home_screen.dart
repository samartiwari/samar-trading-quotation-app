import 'package:flutter/material.dart';
import 'package:samar_trading_quotation/history_screen.dart';
import 'package:samar_trading_quotation/quotation_creation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // We use a LayoutBuilder to make sure it looks good on any window size
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6), // Cleaner, professional off-white
      appBar: AppBar(
        title: const Text(
          "SAMAR TRADING",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Color(0xff2D4030), // Darker green for contrast
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "What would you like to do today?",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 50),

              // The Action Cards Row
              Wrap(
                spacing: 20, // Horizontal space between cards
                runSpacing: 20, // Vertical space if they wrap
                alignment: WrapAlignment.center,
                children: [
                  _DashboardCard(
                    title: "New Quotation",
                    subtitle: "Create a PDF invoice",
                    icon: Icons.post_add_rounded,
                    color: const Color(0xff6F8F72), // Your Sage Green
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const QuotationCreationScreen(),
                        ),
                      );
                    },
                  ),

                  _DashboardCard(
                    title: "View History",
                    subtitle: "Check past records",
                    icon: Icons.history_rounded,
                    color: Colors.blueGrey,
                    isSecondary: true,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const HistoryScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- REUSABLE CARD WIDGET ---
class _DashboardCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isSecondary;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isSecondary = false,
  });

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 260,
          height: 180,
          padding: const EdgeInsets.all(24),
          transform: _isHovered
              ? (Matrix4.identity()..translate(0.0, -4.0, 0.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: widget.isSecondary ? Colors.white : widget.color,
            borderRadius: BorderRadius.circular(20),
            border: widget.isSecondary
                ? Border.all(color: Colors.grey.shade300, width: 2)
                : null,
            boxShadow: _isHovered
                ? [
              BoxShadow(
                color: (widget.isSecondary ? Colors.black : widget.color)
                    .withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ]
                : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.isSecondary
                      ? Colors.grey.shade100
                      : Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: 32,
                  color: widget.isSecondary ? Colors.black54 : Colors.white,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.isSecondary ? Colors.black87 : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.isSecondary
                          ? Colors.grey
                          : Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}