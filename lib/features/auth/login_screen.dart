import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../core/models/research_models.dart';
import '../../core/state/project_state.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isCreateAccountMode = false;
  UserRole _selectedRole = UserRole.researcher;

  // Sign In controllers
  final TextEditingController _emailController = TextEditingController(text: 'sarah.lin@apexmed.edu');
  final TextEditingController _passwordController = TextEditingController(text: '••••••••••••');
  final TextEditingController _regIdController = TextEditingController(text: 'MCI-REG-849204');

  // Create Account controllers
  final TextEditingController _regNameController = TextEditingController();
  final TextEditingController _regTitleController = TextEditingController();
  final TextEditingController _regInstitutionController = TextEditingController();
  final TextEditingController _regDeptController = TextEditingController();
  final TextEditingController _regEmailController = TextEditingController();
  final TextEditingController _regPassController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  void _onRoleChanged(UserRole role) {
    setState(() {
      _selectedRole = role;
      if (role == UserRole.researcher) {
        _emailController.text = 'sarah.lin@apexmed.edu';
      } else {
        _emailController.text = 'm.vance@metroheart.org';
      }
    });
  }

  void _performLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    ref.read(appStateProvider.notifier).switchRole(_selectedRole);

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _performRegistration() async {
    final name = _regNameController.text.trim();
    final title = _regTitleController.text.trim();
    final email = _regEmailController.text.trim();
    final inst = _regInstitutionController.text.trim();
    final dept = _regDeptController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in your name and institutional email.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    ref.read(appStateProvider.notifier).registerNewUser(
          name: name,
          title: title.isNotEmpty ? title : (_selectedRole == UserRole.specialist ? 'Consultant' : 'Clinical Fellow'),
          email: email,
          institution: inst.isNotEmpty ? inst : 'Academic Medical Center',
          department: dept.isNotEmpty ? dept : 'Internal Medicine',
          specialty: dept.isNotEmpty ? dept : 'Clinical Research',
          role: _selectedRole,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created! Welcome to ClinResearch, $name.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _regIdController.dispose();
    _regNameController.dispose();
    _regTitleController.dispose();
    _regInstitutionController.dispose();
    _regDeptController.dispose();
    _regEmailController.dispose();
    _regPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgSurface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Brand Animated Mascot (Transparent, No Background or Circle)
                  Center(
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: Lottie.asset(
                        'assets/animations/Perulogy.json',
                        fit: BoxFit.contain,
                        repeat: true,
                        errorBuilder: (context, error, stackTrace) {
                          return Lottie.asset(
                            'lib/animations/Perulogy.json',
                            fit: BoxFit.contain,
                            repeat: true,
                            errorBuilder: (ctx, err, stack) => const Center(
                              child: Icon(
                                Icons.biotech_rounded,
                                color: AppTheme.accentCyan,
                                size: 52,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ClinResearch Portal',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryNavy,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isCreateAccountMode
                        ? 'Register for verified institutional research access'
                        : 'Evidence-grounded, AI-assisted research workspace',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Role Segment Switcher (2 Roles)
                  _buildRoleSwitcher(),
                  const SizedBox(height: 16),

                  // Sign In / Create Account Toggle Tab
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _isCreateAccountMode = false),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: !_isCreateAccountMode ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: !_isCreateAccountMode
                                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                                    : null,
                              ),
                              child: Text(
                                'Sign In',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: !_isCreateAccountMode ? FontWeight.w700 : FontWeight.w500,
                                  color: !_isCreateAccountMode ? AppTheme.primaryNavy : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _isCreateAccountMode = true),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _isCreateAccountMode ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: _isCreateAccountMode
                                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                                    : null,
                              ),
                              child: Text(
                                'Create Account',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: _isCreateAccountMode ? FontWeight.w700 : FontWeight.w500,
                                  color: _isCreateAccountMode ? AppTheme.primaryNavy : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Main Form Card (Sign In OR Create Account)
                  if (!_isCreateAccountMode)
                    _buildSignInCard()
                  else
                    _buildCreateAccountCard(),

                  const SizedBox(height: 16),

                  // SSO Button
                  OutlinedButton.icon(
                    onPressed: _performLogin,
                    icon: const Icon(Icons.vpn_key_outlined, size: 16, color: AppTheme.primaryNavy),
                    label: const Text(
                      'Institutional SSO / ORCID Login',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        children: [
          _buildRoleTabItem(
            role: UserRole.researcher,
            title: 'Researcher',
            icon: Icons.school_rounded,
            activeColor: AppTheme.researcherColor,
          ),
          _buildRoleTabItem(
            role: UserRole.specialist,
            title: 'Doctor / Specialist',
            icon: Icons.medical_services_rounded,
            activeColor: AppTheme.doctorColor,
          ),
        ],
      ),
    );
  }

  Widget _buildRoleTabItem({
    required UserRole role,
    required String title,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSelected = _selectedRole == role;

    return Expanded(
      child: InkWell(
        onTap: () => _onRoleChanged(role),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.3),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignInCard() {
    Color roleColor;
    String roleHeader;
    switch (_selectedRole) {
      case UserRole.researcher:
        roleColor = AppTheme.researcherColor;
        roleHeader = 'INVESTIGATOR / RESIDENT SIGN-IN';
        break;
      case UserRole.specialist:
      default:
        roleColor = AppTheme.doctorColor;
        roleHeader = 'CONSULTANT / SPECIALIST SIGN-IN';
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: roleColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    roleHeader,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: roleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Email Field
            Text(
              'Institutional Medical Email',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email_outlined, size: 18),
                hintText: 'name@hospital.edu',
              ),
            ),
            const SizedBox(height: 14),

            // Doctor Registration #
            if (_selectedRole == UserRole.specialist) ...[
              Text(
                'Medical Council Registration / NPI #',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _regIdController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.verified_user_outlined, size: 18, color: AppTheme.doctorColor),
                  hintText: 'e.g. MCI-REG-849204',
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Password Field
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Password', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                Text(
                  'Forgot?',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.accentCyan),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 18,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                hintText: '••••••••',
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _performLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: roleColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Enter ${_selectedRole == UserRole.admin ? "Governance Portal" : (_selectedRole == UserRole.specialist ? "Specialist Portal" : "Researcher Portal")}',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateAccountCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_add_alt_1_rounded, size: 18, color: AppTheme.primaryNavy),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'NEW RESEARCHER / DOCTOR REGISTRATION',
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: AppTheme.primaryNavy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Full Name
            Text('Full Name & Academic Credentials', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _regNameController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.badge_outlined, size: 18),
                hintText: 'e.g. Dr. Alex Morgan, MD',
              ),
            ),
            const SizedBox(height: 12),

            // Academic Title & Department
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Designation / Title', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _regTitleController,
                        decoration: const InputDecoration(hintText: 'e.g. Fellow, Consultant'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Department / Specialty', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _regDeptController,
                        decoration: const InputDecoration(hintText: 'e.g. Cardiology, Oncology'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Institution
            Text('Affiliated Medical Center / University', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _regInstitutionController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.account_balance_outlined, size: 18),
                hintText: 'e.g. Apex Institute of Medical Sciences',
              ),
            ),
            const SizedBox(height: 12),

            // Email
            Text('Institutional Email', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _regEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email_outlined, size: 18),
                hintText: 'alex.morgan@apexmed.edu',
              ),
            ),
            const SizedBox(height: 12),

            // Password
            Text('Create Secure Password', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _regPassController,
              obscureText: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock_outline_rounded, size: 18),
                hintText: 'At least 8 characters',
              ),
            ),
            const SizedBox(height: 20),

            // Register Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _performRegistration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryNavy,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Create Account & Enter Portal',
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
