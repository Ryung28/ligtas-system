export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.1"
  }
  public: {
    Tables: {
      access_requests: {
        Row: {
          approved_at: string | null
          approved_by: string | null
          email: string
          full_name: string | null
          id: number
          requested_at: string | null
          status: string | null
          user_id: string
        }
        Insert: {
          approved_at?: string | null
          approved_by?: string | null
          email: string
          full_name?: string | null
          id?: number
          requested_at?: string | null
          status?: string | null
          user_id: string
        }
        Update: {
          approved_at?: string | null
          approved_by?: string | null
          email?: string
          full_name?: string | null
          id?: number
          requested_at?: string | null
          status?: string | null
          user_id?: string
        }
        Relationships: []
      }
      activity_log: {
        Row: {
          action: string
          changes: Json | null
          created_at: string | null
          id: number
          record_id: number | null
          table_name: string
          user_id: string | null
        }
        Insert: {
          action: string
          changes?: Json | null
          created_at?: string | null
          id?: number
          record_id?: number | null
          table_name: string
          user_id?: string | null
        }
        Update: {
          action?: string
          changes?: Json | null
          created_at?: string | null
          id?: number
          record_id?: number | null
          table_name?: string
          user_id?: string | null
        }
        Relationships: []
      }
      auth_debug_logs: {
        Row: {
          error_message: string | null
          id: string
          match_found: boolean | null
          matched_role: string | null
          new_user_email: string | null
          timestamp: string | null
        }
        Insert: {
          error_message?: string | null
          id?: string
          match_found?: boolean | null
          matched_role?: string | null
          new_user_email?: string | null
          timestamp?: string | null
        }
        Update: {
          error_message?: string | null
          id?: string
          match_found?: boolean | null
          matched_role?: string | null
          new_user_email?: string | null
          timestamp?: string | null
        }
        Relationships: []
      }
      authorized_emails: {
        Row: {
          created_at: string | null
          email: string
          full_name: string | null
          role: string | null
        }
        Insert: {
          created_at?: string | null
          email: string
          full_name?: string | null
          role?: string | null
        }
        Update: {
          created_at?: string | null
          email?: string
          full_name?: string | null
          role?: string | null
        }
        Relationships: []
      }
      borrow_logs: {
        Row: {
          actual_return_date: string | null
          approved_at: string | null
          approved_by: string | null
          borrow_date: string
          borrowed_by: string | null
          borrower_contact: string | null
          borrower_email: string | null
          borrower_name: string
          borrower_organization: string | null
          borrower_user_id: string | null
          created_at: string | null
          expected_return_date: string | null
          handed_at: string | null
          handed_by: string | null
          id: number
          inventory_id: number | null
          inventory_item_id: string | null
          item_code: string | null
          item_name: string
          notes: string | null
          purpose: string | null
          quantity: number
          quantity_borrowed: number | null
          received_by_name: string | null
          received_by_user_id: string | null
          return_condition: string | null
          return_notes: string | null
          returned_by: string | null
          status: string
          transaction_type: string
          updated_at: string | null
        }
        Insert: {
          actual_return_date?: string | null
          approved_at?: string | null
          approved_by?: string | null
          borrow_date?: string
          borrowed_by?: string | null
          borrower_contact?: string | null
          borrower_email?: string | null
          borrower_name: string
          borrower_organization?: string | null
          borrower_user_id?: string | null
          created_at?: string | null
          expected_return_date?: string | null
          handed_at?: string | null
          handed_by?: string | null
          id?: number
          inventory_id?: number | null
          inventory_item_id?: string | null
          item_code?: string | null
          item_name: string
          notes?: string | null
          purpose?: string | null
          quantity: number
          quantity_borrowed?: number | null
          received_by_name?: string | null
          received_by_user_id?: string | null
          return_condition?: string | null
          return_notes?: string | null
          returned_by?: string | null
          status?: string
          transaction_type: string
          updated_at?: string | null
        }
        Update: {
          actual_return_date?: string | null
          approved_at?: string | null
          approved_by?: string | null
          borrow_date?: string
          borrowed_by?: string | null
          borrower_contact?: string | null
          borrower_email?: string | null
          borrower_name?: string
          borrower_organization?: string | null
          borrower_user_id?: string | null
          created_at?: string | null
          expected_return_date?: string | null
          handed_at?: string | null
          handed_by?: string | null
          id?: number
          inventory_id?: number | null
          inventory_item_id?: string | null
          item_code?: string | null
          item_name?: string
          notes?: string | null
          purpose?: string | null
          quantity?: number
          quantity_borrowed?: number | null
          received_by_name?: string | null
          received_by_user_id?: string | null
          return_condition?: string | null
          return_notes?: string | null
          returned_by?: string | null
          status?: string
          transaction_type?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "borrow_logs_inventory_id_fkey"
            columns: ["inventory_id"]
            isOneToOne: false
            referencedRelation: "active_inventory"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "borrow_logs_inventory_id_fkey"
            columns: ["inventory_id"]
            isOneToOne: false
            referencedRelation: "inventory"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "borrow_logs_inventory_id_fkey"
            columns: ["inventory_id"]
            isOneToOne: false
            referencedRelation: "inventory_availability"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "borrow_logs_inventory_id_fkey"
            columns: ["inventory_id"]
            isOneToOne: false
            referencedRelation: "inventory_items_with_variants"
            referencedColumns: ["id"]
          },
        ]
      }
      cctv_logs: {
        Row: {
          action_type: string
          address: string | null
          camera_name: string | null
          classification: string | null
          classification_remarks: string | null
          client_name: string | null
          contact_number: string | null
          created_at: string | null
          date_of_action: string
          id: string
          incident_datetime: string | null
          incident_datetime_end: string | null
          office: string | null
          offline_cameras: Json | null
          remarks: string | null
        }
        Insert: {
          action_type: string
          address?: string | null
          camera_name?: string | null
          classification?: string | null
          classification_remarks?: string | null
          client_name?: string | null
          contact_number?: string | null
          created_at?: string | null
          date_of_action: string
          id?: string
          incident_datetime?: string | null
          incident_datetime_end?: string | null
          office?: string | null
          offline_cameras?: Json | null
          remarks?: string | null
        }
        Update: {
          action_type?: string
          address?: string | null
          camera_name?: string | null
          classification?: string | null
          classification_remarks?: string | null
          client_name?: string | null
          contact_number?: string | null
          created_at?: string | null
          date_of_action?: string
          id?: string
          incident_datetime?: string | null
          incident_datetime_end?: string | null
          office?: string | null
          offline_cameras?: Json | null
          remarks?: string | null
        }
        Relationships: []
      }
      chat_messages: {
        Row: {
          content: string
          created_at: string | null
          id: string
          is_read: boolean | null
          receiver_id: string | null
          room_id: string | null
          sender_id: string | null
          status: string | null
        }
        Insert: {
          content: string
          created_at?: string | null
          id?: string
          is_read?: boolean | null
          receiver_id?: string | null
          room_id?: string | null
          sender_id?: string | null
          status?: string | null
        }
        Update: {
          content?: string
          created_at?: string | null
          id?: string
          is_read?: boolean | null
          receiver_id?: string | null
          room_id?: string | null
          sender_id?: string | null
          status?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "chat_messages_receiver_id_fkey"
            columns: ["receiver_id"]
            isOneToOne: false
            referencedRelation: "user_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "chat_messages_sender_id_fkey"
            columns: ["sender_id"]
            isOneToOne: false
            referencedRelation: "user_profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "messages_room_id_fkey"
            columns: ["room_id"]
            isOneToOne: false
            referencedRelation: "chat_rooms"
            referencedColumns: ["id"]
          },
        ]
      }
      chat_rooms: {
        Row: {
          borrow_request_id: number | null
          borrower_user_id: string | null
          created_at: string | null
          id: string
        }
        Insert: {
          borrow_request_id?: number | null
          borrower_user_id?: string | null
          created_at?: string | null
          id?: string
        }
        Update: {
          borrow_request_id?: number | null
          borrower_user_id?: string | null
          created_at?: string | null
          id?: string
        }
        Relationships: [
          {
            foreignKeyName: "chat_rooms_borrow_request_id_fkey"
            columns: ["borrow_request_id"]
            isOneToOne: true
            referencedRelation: "borrow_logs"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "chat_rooms_borrower_user_id_fkey"
            columns: ["borrower_user_id"]
            isOneToOne: false
            referencedRelation: "user_profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      inventory: {
        Row: {
          base_name: string | null
          brand: string | null
          category: string
          created_at: string | null
          deleted_at: string | null
          description: string | null
          equipment_type: string | null
          expiry_alert_days: number | null
          expiry_date: string | null
          id: number
          image_url: string | null
          item_name: string
          item_type: string | null
          low_stock_threshold: number | null
          parent_id: number | null
          serial_number: string | null
          status: string | null
          stock_available: number
          stock_total: number
          storage_location: string | null
          updated_at: string | null
          variant_label: string | null
        }
        Insert: {
          base_name?: string | null
          brand?: string | null
          category: string
          created_at?: string | null
          deleted_at?: string | null
          description?: string | null
          equipment_type?: string | null
          expiry_alert_days?: number | null
          expiry_date?: string | null
          id?: number
          image_url?: string | null
          item_name: string
          item_type?: string | null
          low_stock_threshold?: number | null
          parent_id?: number | null
          serial_number?: string | null
          status?: string | null
          stock_available?: number
          stock_total?: number
          storage_location?: string | null
          updated_at?: string | null
          variant_label?: string | null
        }
        Update: {
          base_name?: string | null
          brand?: string | null
          category?: string
          created_at?: string | null
          deleted_at?: string | null
          description?: string | null
          equipment_type?: string | null
          expiry_alert_days?: number | null
          expiry_date?: string | null
          id?: number
          image_url?: string | null
          item_name?: string
          item_type?: string | null
          low_stock_threshold?: number | null
          parent_id?: number | null
          serial_number?: string | null
          status?: string | null
          stock_available?: number
          stock_total?: number
          storage_location?: string | null
          updated_at?: string | null
          variant_label?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_inventory_parent"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "active_inventory"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fk_inventory_parent"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "inventory"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fk_inventory_parent"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "inventory_availability"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fk_inventory_parent"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "inventory_items_with_variants"
            referencedColumns: ["id"]
          },
        ]
      }
      notification_reads: {
        Row: {
          notification_id: string
          read_at: string | null
          user_id: string
        }
        Insert: {
          notification_id: string
          read_at?: string | null
          user_id: string
        }
        Update: {
          notification_id?: string
          read_at?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "notification_reads_notification_id_fkey"
            columns: ["notification_id"]
            isOneToOne: false
            referencedRelation: "system_notifications"
            referencedColumns: ["id"]
          },
        ]
      }
      storage_locations: {
        Row: {
          created_at: string | null
          id: number
          location_name: string
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          id?: number
          location_name: string
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          id?: number
          location_name?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      system_notifications: {
        Row: {
          created_at: string | null
          id: string
          message: string
          reference_id: string | null
          title: string
          type: string
          user_id: string | null
        }
        Insert: {
          created_at?: string | null
          id?: string
          message: string
          reference_id?: string | null
          title: string
          type: string
          user_id?: string | null
        }
        Update: {
          created_at?: string | null
          id?: string
          message?: string
          reference_id?: string | null
          title?: string
          type?: string
          user_id?: string | null
        }
        Relationships: []
      }
      user_fcm_tokens: {
        Row: {
          created_at: string | null
          device_platform: string | null
          fcm_token: string
          id: string
          last_seen_at: string | null
          user_id: string
        }
        Insert: {
          created_at?: string | null
          device_platform?: string | null
          fcm_token: string
          id?: string
          last_seen_at?: string | null
          user_id: string
        }
        Update: {
          created_at?: string | null
          device_platform?: string | null
          fcm_token?: string
          id?: string
          last_seen_at?: string | null
          user_id?: string
        }
        Relationships: []
      }
      user_profiles: {
        Row: {
          approved_at: string | null
          approved_by: string | null
          created_at: string | null
          department: string | null
          email: string
          fcm_token: string | null
          full_name: string | null
          id: string
          last_read_at: string | null
          last_seen: string | null
          role: string | null
          status: Database["public"]["Enums"]["user_status"]
          updated_at: string | null
        }
        Insert: {
          approved_at?: string | null
          approved_by?: string | null
          created_at?: string | null
          department?: string | null
          email: string
          fcm_token?: string | null
          full_name?: string | null
          id: string
          last_read_at?: string | null
          last_seen?: string | null
          role?: string | null
          status?: Database["public"]["Enums"]["user_status"]
          updated_at?: string | null
        }
        Update: {
          approved_at?: string | null
          approved_by?: string | null
          created_at?: string | null
          department?: string | null
          email?: string
          fcm_token?: string | null
          full_name?: string | null
          id?: string
          last_read_at?: string | null
          last_seen?: string | null
          role?: string | null
          status?: Database["public"]["Enums"]["user_status"]
          updated_at?: string | null
        }
        Relationships: []
      }
    }
    Views: {
      active_inventory: {
        Row: {
          category: string | null
          created_at: string | null
          deleted_at: string | null
          description: string | null
          equipment_type: string | null
          id: number | null
          image_url: string | null
          item_name: string | null
          serial_number: string | null
          status: string | null
          stock_available: number | null
          stock_total: number | null
          updated_at: string | null
        }
        Insert: {
          category?: string | null
          created_at?: string | null
          deleted_at?: string | null
          description?: string | null
          equipment_type?: string | null
          id?: number | null
          image_url?: string | null
          item_name?: string | null
          serial_number?: string | null
          status?: string | null
          stock_available?: number | null
          stock_total?: number | null
          updated_at?: string | null
        }
        Update: {
          category?: string | null
          created_at?: string | null
          deleted_at?: string | null
          description?: string | null
          equipment_type?: string | null
          id?: number | null
          image_url?: string | null
          item_name?: string | null
          serial_number?: string | null
          status?: string | null
          stock_available?: number | null
          stock_total?: number | null
          updated_at?: string | null
        }
        Relationships: []
      }
      inventory_availability: {
        Row: {
          brand: string | null
          category: string | null
          created_at: string | null
          deleted_at: string | null
          description: string | null
          equipment_type: string | null
          expiry_alert_days: number | null
          expiry_date: string | null
          id: number | null
          image_url: string | null
          item_name: string | null
          item_type: string | null
          serial_number: string | null
          status: string | null
          stock_available: number | null
          stock_borrowed: number | null
          stock_pending: number | null
          stock_total: number | null
          stock_truly_available: number | null
          storage_location: string | null
          updated_at: string | null
        }
        Relationships: []
      }
      inventory_items_with_variants: {
        Row: {
          base_name: string | null
          brand: string | null
          category: string | null
          created_at: string | null
          deleted_at: string | null
          description: string | null
          equipment_type: string | null
          expiry_alert_days: number | null
          expiry_date: string | null
          full_name: string | null
          id: number | null
          image_url: string | null
          item_name: string | null
          item_type: string | null
          parent_id: number | null
          serial_number: string | null
          status: string | null
          stock_available: number | null
          stock_total: number | null
          storage_location: string | null
          total_stock: number | null
          updated_at: string | null
          variant_count: number | null
          variant_label: string | null
        }
        Insert: {
          base_name?: string | null
          brand?: string | null
          category?: string | null
          created_at?: string | null
          deleted_at?: string | null
          description?: string | null
          equipment_type?: string | null
          expiry_alert_days?: number | null
          expiry_date?: string | null
          full_name?: never
          id?: number | null
          image_url?: string | null
          item_name?: string | null
          item_type?: string | null
          parent_id?: number | null
          serial_number?: string | null
          status?: string | null
          stock_available?: number | null
          stock_total?: number | null
          storage_location?: string | null
          total_stock?: never
          updated_at?: string | null
          variant_count?: never
          variant_label?: string | null
        }
        Update: {
          base_name?: string | null
          brand?: string | null
          category?: string | null
          created_at?: string | null
          deleted_at?: string | null
          description?: string | null
          equipment_type?: string | null
          expiry_alert_days?: number | null
          expiry_date?: string | null
          full_name?: never
          id?: number | null
          image_url?: string | null
          item_name?: string | null
          item_type?: string | null
          parent_id?: number | null
          serial_number?: string | null
          status?: string | null
          stock_available?: number | null
          stock_total?: number | null
          storage_location?: string | null
          total_stock?: never
          updated_at?: string | null
          variant_count?: never
          variant_label?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "fk_inventory_parent"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "active_inventory"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fk_inventory_parent"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "inventory"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fk_inventory_parent"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "inventory_availability"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fk_inventory_parent"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "inventory_items_with_variants"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Functions: {
      approve_user: {
        Args: { target_role?: string; target_user_id: string }
        Returns: boolean
      }
      check_overdue_and_notify: { Args: never; Returns: undefined }
      get_active_chat_inbox_v2: {
        Args: { staff_uuid: string }
        Returns: {
          chat_borrow_request_id: number
          chat_borrower_full_name: string
          chat_borrower_id: string
          chat_borrower_last_seen: string
          chat_borrower_role: string
          chat_borrower_user_id: string
          chat_last_message_content: string
          chat_last_message_created_at: string
          chat_last_message_sender_id: string
          chat_room_id: string
          chat_unread_count: number
        }[]
      }
      get_full_item_name: {
        Args: { item_row: Database["public"]["Tables"]["inventory"]["Row"] }
        Returns: string
      }
      get_my_role: { Args: never; Returns: string }
      get_user_inbox: {
        Args: { p_limit?: number }
        Returns: {
          created_at: string
          id: string
          is_read: boolean
          message: string
          reference_id: string
          title: string
          type: string
          user_id: string
        }[]
      }
      handle_device_token: {
        Args: { p_platform: string; p_token: string; p_user_id: string }
        Returns: undefined
      }
      increment_inventory: {
        Args: { count: number; item_id: number }
        Returns: undefined
      }
      is_admin: { Args: never; Returns: boolean }
      is_admin_or_editor: { Args: never; Returns: boolean }
      is_staff: { Args: never; Returns: boolean }
      reject_user: { Args: { target_user_id: string }; Returns: boolean }
      update_user_role: {
        Args: { new_role: string; target_user_id: string }
        Returns: boolean
      }
    }
    Enums: {
      user_status: "pending" | "active" | "suspended"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      user_status: ["pending", "active", "suspended"],
    },
  },
} as const
