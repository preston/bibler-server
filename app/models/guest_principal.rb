# frozen_string_literal: true

# Anonymous principal carrying the requested collaboration mode (study "mode", not RBAC).
GuestPrincipal = Struct.new(:study_mode)
