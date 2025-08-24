-- Fix files_updated_by foreign key constraint error
-- The updated_by column should be nullable or have a proper default

-- First, check if updated_by column exists and drop the foreign key constraint temporarily
DO $$ 
BEGIN
    -- Drop the foreign key constraint if it exists
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'files_updated_by_fkey' 
        AND table_name = 'files'
    ) THEN
        ALTER TABLE files DROP CONSTRAINT files_updated_by_fkey;
    END IF;
END $$;

-- Make updated_by nullable if it exists
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'files' 
        AND column_name = 'updated_by'
    ) THEN
        ALTER TABLE files ALTER COLUMN updated_by DROP NOT NULL;
    END IF;
END $$;

-- Add back the foreign key constraint as nullable
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'files' 
        AND column_name = 'updated_by'
    ) THEN  
        ALTER TABLE files 
        ADD CONSTRAINT files_updated_by_fkey 
        FOREIGN KEY (updated_by) REFERENCES auth.users(id);
    END IF;
END $$;

-- Update existing files to have proper updated_by values
UPDATE files 
SET updated_by = created_by 
WHERE updated_by IS NULL AND created_by IS NOT NULL;

-- Update the files table trigger to set updated_by on updates
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'files' 
        AND column_name = 'updated_by'
    ) THEN
        -- Create or replace the update trigger function
        CREATE OR REPLACE FUNCTION update_files_updated_by()
        RETURNS TRIGGER AS $func$
        BEGIN
            NEW.updated_by = auth.uid();
            NEW.updated_at = NOW();
            RETURN NEW;
        END;
        $func$ LANGUAGE plpgsql SECURITY DEFINER;

        -- Drop existing trigger if it exists
        DROP TRIGGER IF EXISTS files_update_trigger ON files;
        
        -- Create the trigger
        CREATE TRIGGER files_update_trigger
            BEFORE UPDATE ON files
            FOR EACH ROW
            EXECUTE FUNCTION update_files_updated_by();
    END IF;
END $$;
